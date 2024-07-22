//
//  SubMapCoordinator.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/22/24.
//

import Foundation
import KakaoMapsSDK

class SubMapCoordinator: NSObject, MapControllerDelegate, KakaoMapEventDelegate {
    private let defaultPosition = GeoCoordinate(longitude: 126.978365, latitude: 37.566691)

    var parent: SubMapRepresentableView
    var controller: KMController?
    var first: Bool

    var longitude: Double?
    var latitude: Double?

    var cameraStoppedHandler: DisposableEventHandler?

    init(parent: SubMapRepresentableView) {
        self.parent = parent
        first = true
        super.init()
    }

    func createController(_ view: KMViewContainer) {
        controller = KMController(viewContainer: view)
        controller?.delegate = self
    }


    func addViews() {
        let mapviewInfo = MapviewInfo(viewName: parent.mapMode.name, defaultPosition: MapPoint(longitude: defaultPosition.longitude, latitude: defaultPosition.latitude))
        controller?.addView(mapviewInfo)
    }

    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        guard let view = controller?.getView(viewName) as? KakaoMap else { return }
        if parent.mySpotVM.longitude == "" {
            moveCamera(to: parent.mapVM.currentLocation)
        } else {
            guard let longitude = Double(parent.mySpotVM.longitude),
                  let latitude = Double(parent.mySpotVM.latitude) else { return }
            moveCamera(to: GeoCoordinate(longitude: longitude, latitude: latitude))
        }

        cameraStoppedHandler = view.addCameraStoppedEventHandler(target: self, handler: SubMapCoordinator.onCameraStopped)
    }

    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("Failed")
    }

    func containerDidResized(_ size: CGSize) {
        let mapView = controller?.getView(parent.mapMode.name) as? KakaoMap
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
        if first {
            let cameraUpdate = CameraUpdate.make(target: MapPoint(
                longitude: defaultPosition.longitude,
                latitude: defaultPosition.latitude
            ), mapView: mapView!)
            mapView?.moveCamera(cameraUpdate)
            first = false
        }
    }

    func moveCamera(to location: GeoCoordinate) {
        guard let view = controller?.getView(parent.mapMode.name) as? KakaoMap else { return }

        let cameraUpdate = CameraUpdate.make(
            target: MapPoint(longitude: location.longitude, latitude: location.latitude),
            zoomLevel: parent.mapMode == .searching ? 15 : 17,
            rotation: 0.0,
            tilt: 0.0,
            mapView: view
        )

        view.animateCamera(
            cameraUpdate: cameraUpdate,
            options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 300)
        )
    }

    func onCameraStopped(_ param: CameraActionEventParam) {
        guard let view = param.view as? KakaoMap else { return }
        let center = view.getPosition(CGPoint(x: view.viewRect.size.width * 0.5, y: view.viewRect.size.height * 0.5))

        let longitude = String(center.wgsCoord.longitude)
        let latitude = String(center.wgsCoord.latitude)
        parent.mySpotVM.tempLongitude = longitude
        parent.mySpotVM.tempLatitude = latitude
        Task { @MainActor in
            parent.mySpotVM.tempAddress = await parent.smokingAreaVM.getRoadAddress(by: Coordinate(longitude: longitude, latitude: latitude))
        }
    }
}
