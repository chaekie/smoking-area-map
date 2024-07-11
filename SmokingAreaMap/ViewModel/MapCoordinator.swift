//
//  MapCoordinator.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/27/24.
//

import Foundation
import KakaoMapsSDK
import SwiftUI

final
class MapCoordinator: NSObject, MapControllerDelegate, KakaoMapEventDelegate {

    var parent: MapView
    var controller: KMController?
    var auth: Bool
    var cachedSmokingAreas: [SmokingArea]

    var cameraStoppedHandler: DisposableEventHandler?
    var cameraStartHandler: DisposableEventHandler?

    private let defaultPosition = GeoCoordinate(longitude: 126.978365, latitude: 37.566691)
    private let spotPoiInfo = PoiInfo(layer: Layer(id: "spotLayer", zOrder: 10000),
                                      style: Style(id: "spotStyle", symbol: UIImage(named: "pin")),
                                      rank: 5)
    private let polygonLayerID = "seoulPolygonLayer"
    private let polygonStyleID = "seoulPolygonLayer"

    init(parent: MapView) {
        self.parent = parent
        self.auth = false
        self.cachedSmokingAreas = parent.smokingAreaVM.smokingAreas
        super.init()
    }

    func createController(_ view: KMViewContainer) {
        controller = KMController(viewContainer: view)
        controller?.delegate = self
    }

    func addViews() {
        let mapviewInfo = MapviewInfo(viewName: MapView.mapViewName,
                                      defaultPosition: MapPoint(
                                        longitude: defaultPosition.longitude,
                                        latitude: defaultPosition.latitude
                                      )
        )
        controller?.addView(mapviewInfo)
    }

    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        guard let view = controller?.getView(viewName) as? KakaoMap else { return }
        let labelManager = view.getLabelManager()
        let shapeManager = view.getShapeManager()

        createLabelLayer(labelManager, poiInfo: spotPoiInfo)
        createPoiStyle(labelManager, poiInfo: spotPoiInfo)
        setCurrentPosiotionPoi(labelManager)

        createPolygonStyleSet(shapeManager, styleID: polygonStyleID)
        let polygonData = getDistrictPolygonData()
        polygonData.forEach { polygon in
            createMapPolygonShape(shapeManager, polygon: polygon, layerID: polygonLayerID, styleID: polygonStyleID)
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
        let currentPoiInfo = PoiInfo(layer: Layer(id: "cpLayer", zOrder: 10001),
                                     style: Style(id: "cpPoiStyle", symbol: UIImage(named: "current_position")),
                                     rank: 10)

        createLabelLayer(manager, poiInfo: currentPoiInfo)
        createPoiStyle(manager, poiInfo: currentPoiInfo)
        parent.mapVM.currentPositionPoi = createPois(manager, poiInfo: currentPoiInfo, location: parent.mapVM.currentLocation)
        parent.mapVM.currentPositionPoi?.show()
    }

    private func createPois(_ manager: LabelManager, poiInfo: PoiInfo, location: GeoCoordinate) -> Poi? {
        let newLayer = manager.getLabelLayer(layerID: poiInfo.layer.id)
        let poiOption = PoiOptions(styleID: poiInfo.style.id)
        poiOption.clickable = true
        poiOption.rank = poiInfo.rank

        return newLayer?.addPoi(option: poiOption, at: MapPoint(longitude: location.longitude, latitude: location.latitude))
    }

    func setPois(_ smokingAreas: [SmokingArea]) {
        guard let view = controller?.getView(MapView.mapViewName) as? KakaoMap else { return }
        let manager = view.getLabelManager()
        if let layer = manager.getLabelLayer(layerID: "spotLayer") {
            layer.clearAllItems()
        }

        smokingAreas.forEach { area in
            let poi = createPois(manager,
                                 poiInfo: spotPoiInfo,
                                 location: GeoCoordinate(longitude: area.longitude, latitude: area.latitude))
            poi?.userObject = area as AnyObject
            let _ = poi?.addPoiTappedEventHandler(target: self, handler: MapCoordinator.poiTappedHandler)
            poi?.show()
        }
    }

    func poiTappedHandler(_ param: PoiInteractionEventParam) {
        guard let info = param.poiItem.userObject as? SmokingArea else { return }
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
        let layer = manager.addShapeLayer(layerID: layerID, zOrder: 10001)
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
        if parent.mapVM.currentLocation.longitude == 0.0 && parent.mapVM.currentLocation.latitude == 0.0 {
            moveCamera(to: defaultPosition)
            setUpFirstDistrict(defaultPosition)
        } else {
            moveCamera(to: parent.mapVM.currentLocation)
            setUpFirstDistrict(parent.mapVM.currentLocation)
        }

        cameraStartHandler = view.addCameraWillMovedEventHandler(target: self, handler: MapCoordinator.onCameraWillMove)
        cameraStoppedHandler = view.addCameraStoppedEventHandler(target: self, handler: MapCoordinator.onCameraStopped)
    }

    func moveCamera(to location: GeoCoordinate) {
        guard let view = controller?.getView(MapView.mapViewName) as? KakaoMap else { return }

        let cameraUpdate = CameraUpdate.make(
            target: MapPoint(longitude: location.longitude, latitude: location.latitude),
            zoomLevel: 15,
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
            guard let district = await parent.smokingAreaVM.getDistrict(
                by: Coordinate(longitude: String(coord.longitude), latitude: String(coord.latitude))
            ) else { return }

            await parent.smokingAreaVM.fetchSmokingArea(district: district)
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

        Task {
            guard let district = await parent.smokingAreaVM.getDistrict(
                by: Coordinate(longitude: String(center.wgsCoord.longitude), latitude: String(center.wgsCoord.latitude))
            ) else {
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
        let layer = manager.getShapeLayer(layerID: polygonLayerID)

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
        guard let view = controller?.getView(MapView.mapViewName) as? KakaoMap else { return }
        let manager = view.getShapeManager()
        let layer = manager.getShapeLayer(layerID: polygonLayerID)
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
        let mapView = controller?.getView(MapView.mapViewName) as? KakaoMap
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
        if parent.isAppear {
            let cameraUpdate = CameraUpdate.make(target: MapPoint(
                longitude: defaultPosition.longitude,
                latitude: defaultPosition.latitude
            ), mapView: mapView!)
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

