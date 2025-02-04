//
//  Constants.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/25/24.
//

import KakaoMapsSDK
import SwiftUI

struct Constants {

    struct Map {
        static let polygonLayerID = "seoulPolygonLayer"
        static let polygonStyleID = "seoulPolygonLayer"
        static let mainMapName = "mainMap"

        static let defaultPosition = GeoCoordinate(longitude: 126.978365, latitude: 37.566691)
        static let spotPoiInfo = PoiInfo(layer: Layer(id: "spotLayer", zOrder: 10000),
                                         style: Style(id: "spotStyle", symbol: UIImage(named: "pin")),
                                         rank: 5)
        static let mySpotPoiInfo = PoiInfo(layer: Layer(id: "mySpotLayer", zOrder: 10001),
                                           style: Style(id: "mySpotStyle", symbol: UIImage(named: "my_pin")),
                                           rank: 5)
        static let currentPoiInfo = PoiInfo(layer: Layer(id: "cpLayer", zOrder: 10001),
                                            style: Style(id: "cpPoiStyle", symbol: UIImage(named: "current_position")),
                                            rank: 10)
    }

    struct BottomSheet {
        static let aniDuration = CGFloat(0.2)
        static let initPosition = CGFloat(1500)
        static let dragVelocityThreshold = CGFloat(1000)
        static let scrollVelocityThreshold = CGFloat(1)
        static let toolbarVisibilityThreshold = UIScreen.screenSize.height * 1/3
        static let largeToSmallDistanceThreshold = CGFloat(30)
        static let smallToLargeDistanceThreshold = CGFloat(40)
        static let sheetCornerRadius = CGFloat(13)
        static let shortDetentRatio = CGFloat(5) / CGFloat(6)
        static let dragIndicatorHeight = CGFloat(20)
        static let headerHeight = CGFloat(48)
    }

}


struct PoiInfo {
    var layer: Layer
    var style: Style
    var rank: Int
}

struct Layer {
    var id: String
    var zOrder: Int
}

struct Style {
    var id: String
    var symbol: UIImage?
}
