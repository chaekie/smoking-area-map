//
//  KaKaoLocal.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/9/24.
//

import Foundation

enum SearchType: String {
    case address
    case keyword
}

struct LocalCoordDataResult: Codable {
    let documents: [Coordinate]
}

struct Coordinate: Codable {
    let longitude, latitude: String

    enum CodingKeys: String, CodingKey {
        case longitude = "x"
        case latitude = "y"
    }
}

struct LocalRegionDataResult: Codable {
    let documents: [Region]
}

struct Region: Codable {
    let siDo, gu, dong: String

    enum CodingKeys: String, CodingKey {
        case siDo = "region_1depth_name"
        case gu = "region_2depth_name"
        case dong = "region_3depth_name"
    }
}
