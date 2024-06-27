//
//  SmokingArea.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/24/24.
//

import Foundation

struct SmokingAreaDataResult: Codable {
    let currentCount: Int
    let data: [SmokingAreaData]
    let matchCount, page, perPage, totalCount: Int
}

struct SmokingAreaData: Codable {
    let district: String
    let address: String
    let longitude: String
    let latitude: String
    let roomType: String
    let space: String

    private enum CodingKeys : String, CodingKey {
        case district = "자치구"
        case address = "시설 구분"
        case longitude = "경도"
        case latitude = "위도"
        case roomType = "시설형태"
        case space = "설치 위치"
    }

    func toSmokingArea() -> SmokingArea {
        let districtEnum = District(rawValue: district) ?? .defaultValue
        let roomTypeEnum = RoomType(rawValue: roomType) ?? .defaultValue
        let spaceEnum = Space(rawValue: space) ?? .defaultValue
        let longitudeDouble = Double(longitude) ?? 0.0
        let latitudeDouble = Double(latitude) ?? 0.0

        return SmokingArea(
            district: districtEnum,
            address: address,
            longitude: longitudeDouble,
            latitude: latitudeDouble,
            roomType: roomTypeEnum,
            space: spaceEnum
        )
    }
}

/// SmokingArea Description
struct SmokingArea: Codable {
    /// 자치구
    let district: District

    /// 건물 주소
    let address: String

    /// 경도
    let longitude: Double

    /// 위도
    let latitude: Double

    /// 개방감 (개방형, 완전개방형)
    let roomType: RoomType

    /// 실내외 구분 (실내, 실외)
    let space: Space
}

enum Space: String, Codable {
    case 실외, 미정

    static let defaultValue: Space = .미정
}

enum RoomType: String, Codable {
    case 개방형, 완전개방형, 미정

    static let defaultValue: RoomType = .미정
}

enum District: String, Codable {
    case 영등포구, 서울

    static let defaultValue: District = .서울
}
