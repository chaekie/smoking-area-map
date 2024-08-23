//
//  CustomSheetModel.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/22/24.
//

import Foundation

struct DetentPositions {
    var closed: CGFloat
    var small: CGFloat
    var large: CGFloat
}

enum Detent {
    case closed
    case small
    case large
}

enum SwipeDirection {
    case up
    case down
}
