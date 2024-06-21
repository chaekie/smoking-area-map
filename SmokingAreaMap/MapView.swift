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
    @Binding var isAppear: Bool
    var coordinator: KakaoMapCoordinator

    static let mapViewName = "smokingAreaMapView"
    @Environment(\.scenePhase) var scenePhase

    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view = KMViewContainer()
        view.sizeToFit()
        context.coordinator.createController(view)
        return view
    }
    
    func updateUIView(_ uiView: KMViewContainer, context: Self.Context) {
        guard let controller = context.coordinator.controller else { return }

            DispatchQueue.main.async {
                if isAppear {
                    if scenePhase == .background || scenePhase == .inactive {
                        controller.pauseEngine()
                    } else {
                        if controller.isEnginePrepared == false { controller.prepareEngine() }
                        if controller.isEngineActive == false { controller.activateEngine() }
                    }
                } else {
                    controller.pauseEngine()
                    controller.resetEngine()
                }
            }
        }
    
    func makeCoordinator() -> KakaoMapCoordinator {
        return coordinator
    }

    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: KakaoMapCoordinator) {
            coordinator.controller?.pauseEngine()
            coordinator.controller?.resetEngine()
    }


    class KakaoMapCoordinator: LocationManager, MapControllerDelegate {

        override init() {
            first = true
            super.init()
        }

        func createController(_ view: KMViewContainer) {
            controller = KMController(viewContainer: view)
            controller?.delegate = self
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

        func addViews() {
            let mapviewInfo = MapviewInfo(
                viewName: MapView.mapViewName,
                defaultPosition: defaultPosition
            )
            controller?.addView(mapviewInfo)
        }

        func addViewSucceeded(_ viewName: String, viewInfoName: String) {
            guard let view = controller?.getView(viewName) as? KakaoMap else { return }
            let _ = shouldMoveToCurrentLocation(view: view)
            setPois(view)
        }

        func containerDidResized(_ size: CGSize) {
            let mapView = controller?.getView(MapView.mapViewName) as? KakaoMap
            mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
            if first {
                let cameraUpdate = CameraUpdate.make(target: defaultPosition, mapView: mapView!)
                mapView?.moveCamera(cameraUpdate)
                first = false
            }
        }

        var controller: KMController?
        var first: Bool

        private let defaultPosition = MapPoint(longitude: 126.978365, latitude: 37.566691)
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

#Preview {
    MapView(isAppear: .constant(false),
            coordinator: MapView.KakaoMapCoordinator())
}

