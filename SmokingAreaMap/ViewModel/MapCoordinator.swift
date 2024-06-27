//
//  MapCoordinator.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/27/24.
//

import Foundation
import KakaoMapsSDK

class MapCoordinator: NSObject, MapControllerDelegate, KakaoMapEventDelegate {

    var parent: MapView
    var controller: KMController?
    var auth: Bool

    private let defaultPosition = MapPoint(longitude: 126.978365, latitude: 37.566691)
    private let spotPoiInfo = PoiInfo(layer: Layer(id: "spotLayer", zOrder: 10000),
                                      style: Style(id: "spotStyle", symbol: UIImage(named: "pin")),
                              rank: 5)

    init(parent: MapView) {
        self.parent = parent
        self.auth = false
        super.init()
    }

    func createController(_ view: KMViewContainer) {
        controller = KMController(viewContainer: view)
        controller?.delegate = self
    }

    func addViews() {
        let mapviewInfo = MapviewInfo(viewName: MapView.mapViewName, defaultPosition: defaultPosition)
        controller?.addView(mapviewInfo)
    }

    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        setCurrentPosiotionPoi()
        moveToCurrentLocation()
    }

    func setPois(_ smokingAreas: [SmokingArea]) {
        guard let view = controller?.getView(MapView.mapViewName) as? KakaoMap else { return }
        let manager = view.getLabelManager()
        if let _ = manager.getLabelLayer(layerID: "spotLayer") { return }

        createLabelLayer(view: view, poiInfo: spotPoiInfo)
        createPoiStyle(view: view, poiInfo: spotPoiInfo)
        smokingAreas.forEach { area in
            let poi = createPois(view: view,
                                 poiInfo: spotPoiInfo,
                                 location: GeoCoordinate(longitude: area.longitude, latitude: area.latitude))
            poi?.userObject = area as AnyObject
            let _ = poi?.addPoiTappedEventHandler(target: self, handler: MapCoordinator.poiTappedHandler)
            poi?.show()
        }
    }

    func poiTappedHandler(_ param: PoiInteractionEventParam) {
        guard let info = param.poiItem.userObject as? SmokingArea else { return }
        dump(info)
        parent.viewModel.selectedSpot = info
        parent.onPoiTapped()
    }

    private func setCurrentPosiotionPoi() {
        guard let view = controller?.getView("mainMap") as? KakaoMap else { return }
        let currentPoiInfo = PoiInfo(layer: Layer(id: "cpLayer", zOrder: 10001), style: Style(id: "cpPoiStyle", symbol: UIImage(named: "current_position")), rank: 10)

        createLabelLayer(view: view, poiInfo: currentPoiInfo)
        createPoiStyle(view: view, poiInfo: currentPoiInfo)
        parent.viewModel.currentPositionPoi = createPois(view: view, poiInfo: currentPoiInfo, location: parent.viewModel.currentLocation)
        parent.viewModel.currentPositionPoi?.show()
    }

    private func createPois(view: KakaoMap, poiInfo: PoiInfo, location: GeoCoordinate) -> Poi? {
        let manager = view.getLabelManager()
        let newLayer = manager.getLabelLayer(layerID: poiInfo.layer.id)
        let poiOption = PoiOptions(styleID: poiInfo.style.id)
        poiOption.clickable = true
        poiOption.rank = poiInfo.rank

        return newLayer?.addPoi(option: poiOption, at: MapPoint(longitude: location.longitude, latitude: location.latitude))
    }

    private func createLabelLayer(view: KakaoMap, poiInfo: PoiInfo) {
        let manager = view.getLabelManager()
        let layerOption = LabelLayerOptions(layerID: poiInfo.layer.id, competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: poiInfo.layer.zOrder)
        let _ = manager.addLabelLayer(option: layerOption)
    }

    private func createPoiStyle(view: KakaoMap, poiInfo: PoiInfo) {
        let manager = view.getLabelManager()
        let iconStyle = PoiIconStyle(symbol: poiInfo.style.symbol, anchorPoint: CGPoint(x: 0.0, y: 0.5))
        let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
        let poiStyle = PoiStyle(styleID: poiInfo.style.id, styles: [perLevelStyle])
        manager.addPoiStyle(poiStyle)
    }

    func moveToCurrentLocation() {
        moveCamera(to: parent.viewModel.currentLocation)
    }

    private func moveToPoi(location: GeoCoordinate) {
        moveCamera(to: location)
    }

    private func moveCamera(to location: GeoCoordinate) {
        guard let view = controller?.getView(MapView.mapViewName) as? KakaoMap else { return }

        let cameraUpdate = CameraUpdate.make(
            target: MapPoint(longitude: location.longitude, latitude: location.latitude),
            zoomLevel: 18,
            rotation: 0.0,
            tilt: 0.0,
            mapView: view
        )

        view.animateCamera(
            cameraUpdate: cameraUpdate,
            options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 300)
        )
    }

    func authenticationSucceeded() {
        if auth == false {
            auth = true
        }

        if parent.isAppear && controller?.isEngineActive == false {
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

    func containerDidResized(_ size: CGSize) {
        let mapView = controller?.getView(MapView.mapViewName) as? KakaoMap
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
        if parent.isAppear {
            let cameraUpdate = CameraUpdate.make(target: defaultPosition, mapView: mapView!)
            mapView?.moveCamera(cameraUpdate)
            parent.isAppear = false
        }
    }

    private struct PoiInfo {
        var layer: Layer
        var style: Style
        var rank: Int
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

