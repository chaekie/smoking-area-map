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

// 주소 -> 좌표계
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

// 좌표계 -> 행정구역
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

// 좌표계 -> 도로명
struct LocalAddressDataResult: Codable {
    let documents: [Address] // count 0 또는 1
}

struct Address: Codable {
    let roadAddress: RoadAddress

    enum CodingKeys: String, CodingKey {
        case roadAddress = "road_address"
    }
}

struct RoadAddress: Codable {
    let addressName: String

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
    }
}
