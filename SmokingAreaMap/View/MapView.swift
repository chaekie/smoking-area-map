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
    @Binding var shouldMove: Bool

    static let mapViewName = "mainMap"
    @Environment(\.scenePhase) var scenePhase

    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view = KMViewContainer()
        view.sizeToFit()
        context.coordinator.createController(view)
        return view
    }

    func updateUIView(_ uiView: KMViewContainer, context: Self.Context) {
        if isAppear && shouldMove {
            context.coordinator.moveToCurrentLocation()
            return
        }

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
        return KakaoMapCoordinator(isAppear: $isAppear)
    }

    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: KakaoMapCoordinator) {
        coordinator.controller?.pauseEngine()
        coordinator.controller?.resetEngine()
    }

    class KakaoMapCoordinator: LocationManager, MapControllerDelegate {

        init(isAppear: Binding<Bool>) {
            _isAppear = isAppear
            self.auth = false
            super.init()
        }

        func createController(_ view: KMViewContainer) {
            controller = KMController(viewContainer: view)
            controller?.delegate = self
        }

        func moveToCurrentLocation() {
            moveCamera(location: currentLocation)
        }

        func moveCamera(location: GeoCoordinate) {
            guard let view = controller?.getView(MapView.mapViewName) as? KakaoMap else { return }

            let cameraUpdate = CameraUpdate.make(
                target: MapPoint(longitude: location.longitude,
                                 latitude: location.latitude),
                zoomLevel: 17,
                rotation: 0.0,
                tilt: 0.0,
                mapView: view
            )

            view.animateCamera(
                cameraUpdate: cameraUpdate,
                options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 300)
            )
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

        func authenticationSucceeded() {
            if auth == false {
                auth = true
            }

            if isAppear && controller?.isEngineActive == false {
                controller?.activateEngine()
            }
        }

        func authenticationFailed(_ errorCode: Int, desc: String) {
            auth = false

            let error: SAError
            switch errorCode {
            case 400:
                error = SAError(.wrongParameter)
            case 401:
                error = SAError(.wrongApiKey)
            case 403:
                error = SAError(.unauthorizedApiKey)
            case 429:
                error = SAError(.quotaExceeded)
            case 499:
                error = SAError(.networkUnavailable, description: "네트워크 오류로 5초 후 재시도..")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    print("retry auth...")
                    self.controller?.prepareEngine()
                }
            default:
                error = SAError(.unknownError, description: "error code: \(errorCode)\ndesc: \(desc)")
            }
            dump(error)
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
            moveToCurrentLocation()
            setPois(view)
        }

        func containerDidResized(_ size: CGSize) {
            let mapView = controller?.getView(MapView.mapViewName) as? KakaoMap
            mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
            if isAppear {
                let cameraUpdate = CameraUpdate.make(target: defaultPosition, mapView: mapView!)
                mapView?.moveCamera(cameraUpdate)
                isAppear = false
            }
        }

        var controller: KMController?
        @Binding var isAppear: Bool
        var auth: Bool

        private let defaultPosition = MapPoint(longitude: 126.978365, latitude: 37.566691)
        private let currentPositionLayer = Layer(id: "cpLayer", zOrder: 10001)
        private let currentPositionStyle = Style(id: "cpPoiStyle",
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
    MapView(isAppear: .constant(false), shouldMove: .constant(false))
}

