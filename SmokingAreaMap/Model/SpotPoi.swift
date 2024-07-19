//
//  SpotPoi.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/19/24.
//

import Foundation

protocol SpotPoi {
    var longitude: Double { get }
    var latitude: Double { get }
    var address: String { get }
}
