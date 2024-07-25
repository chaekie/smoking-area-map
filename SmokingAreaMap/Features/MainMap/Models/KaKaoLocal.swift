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

// 좌표계 -> 지번 주소
struct LocalAddressDataResult: Codable {
    let documents: [LocalAddressDocument]
}

struct LocalAddressDocument: Codable {
    let address: Address

    enum CodingKeys: String, CodingKey {
        case address
    }
}

struct Address: Codable {
    let fullAddress, siDo, gu, dong, mountainYn, mainAddressNo, subAddressNo: String

    enum CodingKeys: String, CodingKey {
        case fullAddress = "address_name"
        case siDo = "region_1depth_name"
        case gu = "region_2depth_name"
        case dong = "region_3depth_name"
        case mountainYn = "mountain_yn"
        case mainAddressNo = "main_address_no"
        case subAddressNo = "sub_address_no"
    }
}
