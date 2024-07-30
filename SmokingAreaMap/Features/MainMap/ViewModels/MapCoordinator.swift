//
//  MapCoordinator.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/27/24.
//

import Foundation
import KakaoMapsSDK
import SwiftUI

final class MapCoordinator: NSObject, MapControllerDelegate, KakaoMapEventDelegate {
    var parent: MapRepresentableView
    var controller: KMController?
    var auth: Bool

    private var cameraStoppedHandler: DisposableEventHandler?
    private var cameraStartHandler: DisposableEventHandler?

    init(parent: MapRepresentableView) {
        self.parent = parent
        self.auth = false
        super.init()
    }

    func createController(_ view: KMViewContainer) {
        controller = KMController(viewContainer: view)
        controller?.delegate = self
    }

    func addViews() {
        let longitude = parent.mapVM.currentLocation.longitude
        let latitude = parent.mapVM.currentLocation.latitude

        let finalLongitude = (longitude != 0.0) ? longitude : Constants.Map.defaultPosition.longitude
        let finalLatitude = (latitude != 0.0) ? latitude : Constants.Map.defaultPosition.latitude

        let mapviewInfo = MapviewInfo(
            viewName: Constants.Map.mainMapName,
            defaultPosition: MapPoint(longitude: finalLongitude, latitude: finalLatitude)
        )

        controller?.addView(mapviewInfo)
        setUpFirstDistrict(GeoCoordinate(longitude: finalLongitude, latitude: finalLatitude))
    }

    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        guard let view = controller?.getView(viewName) as? KakaoMap else { return }
        let labelManager = view.getLabelManager()
        let shapeManager = view.getShapeManager()

        [Constants.Map.currentPoiInfo, Constants.Map.spotPoiInfo, Constants.Map.mySpotPoiInfo].forEach { poiInfo in
            createLabelLayer(labelManager, poiInfo: poiInfo)
            createPoiStyle(labelManager, poiInfo: poiInfo)
        }

        setCurrentPosiotionPoi(labelManager)
        setPois(parent.smokingAreaVM.mySpots, poiInfo: Constants.Map.mySpotPoiInfo)

        createPolygonStyleSet(shapeManager, styleID: Constants.Map.polygonStyleID)
        let polygonData = getDistrictPolygonData()
        polygonData.forEach { polygon in
            createMapPolygonShape(shapeManager, polygon: polygon, layerID: Constants.Map.polygonLayerID, styleID: Constants.Map.polygonStyleID)
        }

        setUpCamera(view)
    }

    private func createLabelLayer(_ manager: LabelManager, poiInfo: PoiInfo) {
        let layerOption = LabelLayerOptions(
            layerID: poiInfo.layer.id,
            competitionType: .none,
            competitionUnit: .poi,
            orderType: .rank,
            zOrder: poiInfo.layer.zOrder
        )
        let _ = manager.addLabelLayer(option: layerOption)
    }

    private func createPoiStyle(_ manager: LabelManager, poiInfo: PoiInfo) {
        let iconStyle = PoiIconStyle(symbol: poiInfo.style.symbol, anchorPoint: CGPoint(x: 0.0, y: 0.5))
        let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
        let poiStyle = PoiStyle(styleID: poiInfo.style.id, styles: [perLevelStyle])
        manager.addPoiStyle(poiStyle)
    }

    private func setCurrentPosiotionPoi(_ manager: LabelManager) {
        parent.mapVM.currentPositionPoi = createPois(manager, poiInfo: Constants.Map.currentPoiInfo, location: parent.mapVM.currentLocation)
        parent.mapVM.currentPositionPoi?.show()
    }

    private func createPois(_ manager: LabelManager, poiInfo: PoiInfo, location: GeoCoordinate) -> Poi? {
        guard let newLayer = manager.getLabelLayer(layerID: poiInfo.layer.id) else { return nil }
        let poiOption = PoiOptions(styleID: poiInfo.style.id)
        poiOption.clickable = true
        poiOption.rank = poiInfo.rank

        return newLayer.addPoi(option: poiOption, at: MapPoint(longitude: location.longitude, latitude: location.latitude))
    }

    func setPois<T: SpotPoi>(_ spots: [T], poiInfo: PoiInfo) {
        guard let view = controller?.getView(Constants.Map.mainMapName) as? KakaoMap else { return }
        let manager = view.getLabelManager()
        if let layer = manager.getLabelLayer(layerID: poiInfo.layer.id) {
            layer.clearAllItems()
        }

        spots.forEach { spot in
            guard let poi = createPois(manager, poiInfo: poiInfo, location: GeoCoordinate(longitude: spot.longitude, latitude: spot.latitude)) else { return }
            poi.userObject = spot as AnyObject
            let _ = poi.addPoiTappedEventHandler(target: self, handler: MapCoordinator.poiTappedHandler)
            poi.show()
        }
    }

    func poiTappedHandler(_ param: PoiInteractionEventParam) {
        guard let info = param.poiItem.userObject as? SpotPoi else { return }
        parent.mapVM.selectedSpot = info
        parent.onPoiTapped()
    }

    private func createPolygonStyleSet(_ manager: ShapeManager, styleID: String) {
        let farStyle = PerLevelPolygonStyle(color: UIColor(red: 0.5, green: 0.6, blue: 0.9, alpha: 0.8),
                                            strokeWidth: 2,
                                            strokeColor: UIColor.systemBlue, level: 0)
        let closeStyle = PerLevelPolygonStyle(color: UIColor(red: 0.5, green: 0.6, blue: 0.9, alpha: 0.2),
                                              strokeWidth: 2,
                                              strokeColor: UIColor.systemBlue, level: 14)

        let polygonStyle = PolygonStyle(styles: [farStyle, closeStyle])
        let styleSet = PolygonStyleSet(styleSetID: styleID, styles: [polygonStyle])

        manager.addPolygonStyleSet(styleSet)
    }

    private func getDistrictPolygonData() -> [Feature] {
        do {
            guard let polygonJSON = NSDataAsset(name: "SeoulPolygon") else { return [] }
            let polygonData = try JSONDecoder().decode(SeoulPolygonDataResult.self, from: polygonJSON.data)
            return polygonData.features
        } catch {
            dump(SAError(.jsonDecodingFailed))
        }
        return []
    }

    private func createMapPolygonShape(_ manager: ShapeManager, polygon: Feature, layerID: String, styleID: String) {
        var layer = manager.getShapeLayer(layerID: layerID)
        if layer == nil {
            layer = manager.addShapeLayer(layerID: layerID, zOrder: 10001)
        }
        let options = MapPolygonShapeOptions(shapeID: polygon.properties.name, styleID: styleID, zOrder: 1)
        let mapPointPolygonData = polygon.geometry.coordinates.map {
            $0.map { MapPoint(longitude: $0[0], latitude: $0[1]) }
        }
        let polygons = mapPointPolygonData.map { MapPolygon(exteriorRing: $0, hole: nil, styleIndex: 0) }
        polygons.forEach { polygon in
            options.polygons.append(polygon)
        }
        _ = layer?.addMapPolygonShape(options)
    }

    private func setUpCamera(_ view: KakaoMap) {
        cameraStartHandler = view.addCameraWillMovedEventHandler(target: self, handler: MapCoordinator.onCameraWillMove)
        cameraStoppedHandler = view.addCameraStoppedEventHandler(target: self, handler: MapCoordinator.onCameraStopped)
    }

    func moveCamera(to location: GeoCoordinate) {
        guard let view = controller?.getView(Constants.Map.mainMapName) as? KakaoMap else { return }

        let cameraUpdate = CameraUpdate.make(
            target: MapPoint(longitude: location.longitude, latitude: location.latitude),
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

    private func setUpFirstDistrict(_ coord: GeoCoordinate) {
        Task {
            guard let address = await parent.smokingAreaVM.getAddress(by: Coordinate(longitude: String(coord.longitude), latitude: String(coord.latitude))),
                  let district = await parent.smokingAreaVM.getDistrictInfo(by: address.gu) else { return }

            await parent.smokingAreaVM.fetchSmokingArea(district: district)
            await setPois(parent.smokingAreaVM.smokingAreas, poiInfo: Constants.Map.spotPoiInfo)
            await MainActor.run {
                parent.mapVM.oldDistrictValue = district
                parent.mapVM.newDistrictValue = district
            }
        }
    }

    func onCameraWillMove(_ param: CameraActionEventParam) {
        switch param.by {
        case .doubleTapZoomIn: print("move by: doubleTapZoomIn")
        case .twoFingerTapZoomOut: print("move by: twoFingerTapZoomOut")
        case .pan: print("move by: pan")
        case .rotate: print("move by: rotate")
        case .zoom: print("move by: zoom")
        case .tilt: print("move by: tilt")
        case .longTapAndDrag: print("move by: longTapAndDrag")
        case .rotateZoom: print("move by: rotateZoom")
        case .oneFingerZoom: print("move by: oneFingerZoom")
        case .notUserAction: print("move by: notUserAction")
        @unknown default: print("move by: default")
        }
    }

    func onCameraStopped(_ param: CameraActionEventParam) {
        guard let view = param.view as? KakaoMap else { return }
        let center = view.getPosition(CGPoint(x: view.viewRect.size.width * 0.5, y: view.viewRect.size.height * 0.5))
        let longitude = String(center.wgsCoord.longitude)
        let latitude = String(center.wgsCoord.latitude)

        Task {
            guard let address = await parent.smokingAreaVM.getAddress(by: Coordinate(longitude: longitude, latitude: latitude)),
                  let district = await parent.smokingAreaVM.getDistrictInfo(by: address.gu) else {
                updateFocusedPolygon(view, district: nil)
                return
            }

            await MainActor.run {
                withAnimation(.easeIn(duration: 0.2)) {
                    updateFocusedPolygon(view, district: district)
                    parent.mapVM.newDistrictValue = district
                }
            }
        }
    }

    private func updateFocusedPolygon(_ view: KakaoMap, district: DistrictInfo?) {
        let manager = view.getShapeManager()
        let layer = manager.getShapeLayer(layerID: Constants.Map.polygonLayerID)

        guard let district else {
            layer?.hideAllPolygonShapes()
            return
        }

        if parent.mapVM.oldDistrictValue.name == "" || parent.mapVM.oldDistrictValue.name == district.name {
            layer?.hideAllPolygonShapes()
        } else if parent.mapVM.oldDistrictValue.name != district.name {
            let oldShape = layer?.getMapPolygonShape(shapeID: parent.mapVM.newDistrictValue.name)
            let newShape = layer?.getMapPolygonShape(shapeID: district.name)
            oldShape?.hide()
            newShape?.show()
        }
    }

    func hideAllPolygons() {
        guard let view = controller?.getView(Constants.Map.mainMapName) as? KakaoMap else { return }
        let manager = view.getShapeManager()
        let layer = manager.getShapeLayer(layerID: Constants.Map.polygonLayerID)
        layer?.hideAllPolygonShapes()
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
        let mapView = controller?.getView(Constants.Map.mainMapName) as? KakaoMap
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
        if parent.isAppear {
            let cameraUpdate = CameraUpdate.make(target: MapPoint(
                longitude: Constants.Map.defaultPosition.longitude,
                latitude: Constants.Map.defaultPosition.latitude
            ), mapView: mapView!)
            mapView?.moveCamera(cameraUpdate)
            parent.isAppear = false
        }
    }
}

