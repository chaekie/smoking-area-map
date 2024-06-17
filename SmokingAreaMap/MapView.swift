//
//  MapView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/11/24.
//

import KakaoMapsSDK
import SwiftUI

struct MapView: UIViewRepresentable {
    static let mapViewName = "smokingAreaMapView"
    @Binding var draw: Bool
    @Binding var coordinator: KakaoMapCoordinator

    @EnvironmentObject var locationManager: LocationManager
    @State private var isInCurrentLocation = false

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

                if isInCurrentLocation == false {
                    let status = UserDefaults.standard.string(forKey: "locationStatus")
                    guard let status = status else { return }

                    isInCurrentLocation = locationManager.shouldMoveToCurrentLocation(
                        controller: controller,
                        status: status
                    )
                }
            }
        }
        else {
            controller.pauseEngine()
            controller.resetEngine()
        }
    }

    func makeCoordinator() -> KakaoMapCoordinator {
        return coordinator
    }

    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: KakaoMapCoordinator) {
    }

    class KakaoMapCoordinator: NSObject, MapControllerDelegate {
        private let defaultPostion = MapPoint(longitude: 126.978365, latitude: 37.566691)
        
        var controller: KMController?
        var container: KMViewContainer?
        var first: Bool
        var auth: Bool

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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(draw: .constant(false),
                coordinator: .constant(MapView.KakaoMapCoordinator())
        )
    }
}
