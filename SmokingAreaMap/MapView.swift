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
    @Binding var draw: Bool
    @Binding var coordinator: KakaoMapCoordinator

    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view: KMViewContainer = KMViewContainer(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

        context.coordinator.createController(view)

        return view
    }

    func updateUIView(_ uiView: KMViewContainer, context: Self.Context) {
        guard let controller = coordinator.controller else { return }

        if draw {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if controller.isEnginePrepared == false {
                    controller.prepareEngine()
                }

                if controller.isEngineActive == false {
                    controller.activateEngine()
                }
            }
        } else {
            controller.pauseEngine()
            controller.resetEngine()
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

        func createController(_ view: KMViewContainer) {
            container = view
            controller = KMController(viewContainer: view)
            controller?.delegate = self
        }

        override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            currentLocation.longitude = locations[0].coordinate.longitude
            currentLocation.latitude = locations[0].coordinate.latitude

            currentPositionPoi?
                .moveAt(MapPoint(longitude: currentLocation.longitude, latitude: currentLocation.latitude), duration: 300)
        }

        private func setPois(_ view: KakaoMap) {
            createLabelLayer(view: view, layer: currentPositionLayer)
            createPoiStyle(view: view, style: currentPositionStyle)
            createPois(view: view, layer: currentPositionLayer, style: currentPositionStyle)
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
            let newLayer = manager.getLabelLayer(layerID: layer.id)
            let poiOption = PoiOptions(styleID: style.id)
            poiOption.rank = 0

            currentPositionPoi = newLayer?.addPoi(option: poiOption,
                                     at: MapPoint(longitude: currentLocation.longitude,
                                                  latitude: currentLocation.latitude))
            currentPositionPoi?.show()
        }

        private func viewInit(viewName: String) {
            guard let view = controller?.getView(viewName) as? KakaoMap else {
                return
            }
            let _ = shouldMoveToCurrentLocation(view: view)
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
                                                 zOrder: 1001)
        private let currentPositionStyle = Style(id: "currentPositionPoiStyle",
                                                 symbol: UIImage(systemName: "circle.circle.fill")?.withTintColor(.red))
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

