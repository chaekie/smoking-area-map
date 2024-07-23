//
//  MapMode.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/22/24.
//

import Foundation

enum MapMode {
    case searching
    case showing

    var name: String {
        switch self {
        case .searching:
            "searching_mySpot"
        case .showing:
            "showing_mySpot"
        }
    }

    var height: CGFloat {
        switch self {
        case .searching:
            return .infinity
        case .showing:
            return 250
        }
    }

    var zoomLevel: Int {
        switch self {
        case .searching:
            return 15
        case .showing:
            return 17
        }
    }
}
