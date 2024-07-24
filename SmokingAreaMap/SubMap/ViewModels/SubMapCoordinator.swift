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

    var longitude: Double?
    var latitude: Double?

    var cameraStoppedHandler: DisposableEventHandler?

    init(parent: SubMapRepresentableView) {
        self.parent = parent
        super.init()
    }

    func createController(_ view: KMViewContainer) {
        controller = KMController(viewContainer: view)
        controller?.delegate = self
    }

    func addViews() {
        let longitude = Double(parent.mySpotVM.longitude) ?? defaultPosition.longitude
        let latitude = Double(parent.mySpotVM.latitude) ?? defaultPosition.latitude

        let mapviewInfo = MapviewInfo(
            viewName: parent.mapMode.name,
            defaultPosition: MapPoint(longitude: longitude, latitude: latitude),
            defaultLevel: parent.mapMode.zoomLevel
        )

        controller?.addView(mapviewInfo)
    }

    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        guard let view = controller?.getView(viewName) as? KakaoMap else { return }

        setUpCamera(view)
    }

    private func setUpCamera(_ view: KakaoMap) {
        cameraStoppedHandler = view.addCameraStoppedEventHandler(target: self, handler: SubMapCoordinator.onCameraStopped)
    }

    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print(#function)
    }

    func containerDidResized(_ size: CGSize) {
        print(#function)
    }

    func moveCamera(to location: GeoCoordinate, zoomLevel: Int = 15, duration: UInt = 1) {
        guard let view = controller?.getView(parent.mapMode.name) as? KakaoMap else { return }

        let cameraUpdate = CameraUpdate.make(
            target: MapPoint(longitude: location.longitude, latitude: location.latitude),
            zoomLevel: zoomLevel,
            rotation: 0.0,
            tilt: 0.0,
            mapView: view
        )

        view.animateCamera(
            cameraUpdate: cameraUpdate,
            options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: duration)
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
            guard let address = await parent.smokingAreaVM.getAddress(by: Coordinate(longitude: longitude, latitude: latitude)) else { return }
            parent.mySpotVM.tempAddress = address.fullAddress
        }
    }
}
