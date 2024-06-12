//
//  MapView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/11/24.
//

import KakaoMapsSDK
import SwiftUI

struct MapView: UIViewRepresentable {
    @Binding var draw: Bool
    @Binding var coordinator: KakaoMapCoordinator
    static let mapViewName = "smokingAreaMapView"

    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view: KMViewContainer = KMViewContainer(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

        context.coordinator.createController(view)

        return view
    }

    func updateUIView(_ uiView: KMViewContainer, context: Self.Context) {
        if draw {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if context.coordinator.controller?.isEnginePrepared == false {
                    context.coordinator.controller?.prepareEngine()
                }

                if context.coordinator.controller?.isEngineActive == false {
                    context.coordinator.controller?.activateEngine()
                }
            }
        }
        else {
            context.coordinator.controller?.pauseEngine()
            context.coordinator.controller?.resetEngine()
        }
    }

    func makeCoordinator() -> KakaoMapCoordinator {
        return coordinator
    }

    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: KakaoMapCoordinator) {
    }

    class KakaoMapCoordinator: NSObject, MapControllerDelegate {
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
        }

        func containerDidResized(_ size: CGSize) {
            let mapView: KakaoMap? = controller?.getView(MapView.mapViewName) as? KakaoMap
            mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
            if first {
                let cameraUpdate: CameraUpdate = CameraUpdate.make(target: defaultPostion, mapView: mapView!)
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(draw: .constant(false), 
                coordinator: .constant(MapView.KakaoMapCoordinator())
        )
    }
}
