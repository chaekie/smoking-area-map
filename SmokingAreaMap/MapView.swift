//
//  MapView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/11/24.
//

import CoreLocation
import KakaoMapsSDK
import SwiftUI

struct MapView: UIViewRepresentable {
    static let mapViewName = "smokingAreaMapView"
    @EnvironmentObject var locationManager: LocationManager
    @Binding var draw: Bool
    @Binding var coordinator: KakaoMapCoordinator

    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view: KMViewContainer = KMViewContainer(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

        context.coordinator.createController(view)

        return view
    }

    func updateUIView(_ uiView: KMViewContainer, context: Self.Context) {
        guard let controller = coordinator.controller else {
            return
        }

        if draw {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if controller.isEnginePrepared == false {
                    controller.prepareEngine()
                }

                if controller.isEngineActive == false {
                    controller.activateEngine()
                }
            }
        }
    }

    func makeCoordinator() -> KakaoMapCoordinator {
        return coordinator
    }

    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: KakaoMapCoordinator) {
    }

    class KakaoMapCoordinator: LocationManager, MapControllerDelegate {
        
        override init() {
            first = true
            auth = false
            super.init()
        }

        deinit {
            controller?.pauseEngine()
            controller?.resetEngine()
        }

        func createController(_ view: KMViewContainer) {
            container = view
            controller = KMController(viewContainer: view)
            controller?.delegate = self
        }

        private func createLabelLayer(view: KakaoMap, layer: Layer) {
            let manager = view.getLabelManager()
            let layerOption = LabelLayerOptions(layerID: layer.id, competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: layer.zOrder)
            let _ = manager.addLabelLayer(option: layerOption)
        }

        private func createPoiStyle(view: KakaoMap, style: Style)  {
            let manager = view.getLabelManager()
            let iconStyle = PoiIconStyle(symbol: style.symbol, anchorPoint: CGPoint(x: 0.0, y: 0.5))
            let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
            let poiStyle = PoiStyle(styleID: style.id, styles: [perLevelStyle])
            manager.addPoiStyle(poiStyle)
        }

        private func createPois(view: KakaoMap, layer: Layer, style: Style) {
            let manager = view.getLabelManager()
            let layer = manager.getLabelLayer(layerID: layer.id)
            layer?.clearAllItems()
            let poiOption = PoiOptions(styleID: style.id)
            poiOption.rank = 0

            guard let coordinate = lastLocation?.coordinate else { return }
            let poi1 = layer?.addPoi(option: poiOption,
                                     at: MapPoint(longitude: coordinate.longitude,
                                                  latitude: coordinate.latitude),
                                     callback: {(_ poi: (Poi?)) -> Void in
                print("")
            })
            poi1?.show()
        }

        override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            lastLocation = location

            if let view = controller?.getView(MapView.mapViewName) as? KakaoMap {
                createPois(view: view, layer: currentPositionLayer, style: currentPositionStyle)
            }

        }

        private func setPois(_ view: KakaoMap) {
            createLabelLayer(view: view, layer: currentPositionLayer)
            createLabelLayer(view: view, layer: spotLayer)

            createPoiStyle(view: view, style: currentPositionStyle)
            createPoiStyle(view: view, style: spotStyle)

            createPois(view: view, layer: currentPositionLayer, style: currentPositionStyle)
//            createPois(view: view, layer: spotLayer, style: spotStyle)
        }

        private func viewInit(viewName: String) {
            let status = UserDefaults.standard.string(forKey: "locationStatus")
            guard let status = status,
                  let view = controller?.getView(viewName) as? KakaoMap else {
                return
            }
            let _ = shouldMoveToCurrentLocation(view: view, status: status)
            setPois(view)
        }

        func addViews() {
            let mapviewInfo: MapviewInfo = MapviewInfo(
                viewName: MapView.mapViewName,
                viewInfoName: "map",
                defaultPosition: defaultPostion
            )
            controller?.addView(mapviewInfo)
        }

        func addViewSucceeded(_ viewName: String, viewInfoName: String) {
            let view = controller?.getView(MapView.mapViewName)
            view?.viewRect = container!.bounds
            viewInit(viewName: viewName)
        }

        func containerDidResized(_ size: CGSize) {
            let mapView = controller?.getView(MapView.mapViewName) as? KakaoMap
            mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
            if first {
                let cameraUpdate = CameraUpdate.make(target: defaultPostion, mapView: mapView!)
                mapView?.moveCamera(cameraUpdate)
                first = false
            }
        }

        func authenticationSucceeded() {
            auth = true
        }

        var controller: KMController?
        var container: KMViewContainer?
        var first: Bool
        var auth: Bool

        private let defaultPostion = MapPoint(longitude: 126.978365, latitude: 37.566691)
        private let currentPositionLayer = Layer(id: "currentPositionLayer",
                                                 zOrder: 10001)
        private let spotLayer = Layer(id: "spotLayer",
                                      zOrder: 10002)
        private let currentPositionStyle = Style(id: "currentPositionPoiStyle",
                                                 symbol: UIImage(systemName: "circle.circle.fill")?.withTintColor(.red))
        private let spotStyle = Style(id: "spotStyle",
                                      symbol: UIImage(systemName: "mappin")?.withTintColor(.blue))
    }

    private struct Layer {
        var id: String
        var zOrder: Int
    }

    private struct Style {
        var id: String
        var symbol: UIImage?
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(draw: .constant(false),
                coordinator: .constant(MapView.KakaoMapCoordinator())
        )
    }
}
