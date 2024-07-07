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
    let address1: String?
    let address2: String?
    let address3: String?
    let address4: String?
    let address5: String?
    let address6: String?
    let address7: String?
    let address8: String?
    let address9: String?
    let address10: String?
    let address11: String?
    let address12: String?
    let address13: String?

    let longitude: String?
    let latitude: String?

    let roomType1: String?
    let roomType2: String?
    let roomType3: String?

    private enum CodingKeys : String, CodingKey {
        case address1 = "서울특별시 용산구 설치 위치"
        case address2 = "영업소소재지(도로 명)"
        case address3 = "설치도로명주소"
        case address4 = "도로명주소"
        case address5 = "주소"
        case address6 = "위치"
        case address7 = "시설 구분"
        case address8 = "설치 위치"
        case address9 = "설치위치"
        case address10 = "설치위치 상세"
        case address11 = "건물명"
        case address12 = "시설명(업소)"
        case address13 = "시설명"

        case longitude = "경도"
        case latitude = "위도"

        case roomType1 = "시설형태"
        case roomType2 = "흡연실 형태"
        case roomType3 = "구분"
    }

    func getWholeAddress(from districtName: String) -> String {
        var address = districtName

        switch District(rawValue: address) {
        case .yeongdeungpoGu:
            address = ["서울특별시", districtName, address7].compactMap { $0 }.joined(separator: " ")
            break
        case .seongbukGu, .seodaemunGu, .yangcheonGu, .gwanakGu, .dongdaemunGu, .seochoGu, .gangseoGu:
            address = ["서울특별시", districtName, address8, address9, address10].compactMap { $0 }.joined(separator: " ")
            break
        default: address = [address1, address2, address3, address4, address5, address6, address8, address9, address11, address12, address13].compactMap { $0 }.joined(separator: " ")
        }
        return address
    }

    func toSmokingArea(district: DistrictInfo) -> SmokingArea {
        let addressString = getWholeAddress(from: district.name)
        let roomTypeString = [roomType1, roomType2, roomType3].compactMap { $0 }.joined(separator: " ")


        var longitudeDouble: Double = 0.0
        var latitudeDouble: Double = 0.0


        if let longitude = longitude {
            longitudeDouble = Double(longitude) ?? 0.0
        }
        if let latitude = latitude {
            latitudeDouble = Double(latitude) ?? 0.0
        }

        return SmokingArea(
            district: district,
            address: addressString,
            longitude: longitudeDouble,
            latitude: latitudeDouble,
            roomType: roomTypeString
        )
    }
}

/// SmokingArea Description
struct SmokingArea: Codable, Equatable {

    /// 자치구
    let district: DistrictInfo

    /// 주소
    let address: String

    /// 경도
    let longitude: Double

    /// 위도
    let latitude: Double

    /// 개방감
    let roomType: String?
}
