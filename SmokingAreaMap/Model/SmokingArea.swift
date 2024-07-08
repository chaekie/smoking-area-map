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

    let businessType: String?

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

        case businessType = "업종"

        case longitude = "경도"
        case latitude = "위도"

        case roomType1 = "시설형태"
        case roomType2 = "흡연실 형태"
        case roomType3 = "구분"
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


enum SearchType: String {
    case address
    case keyword
}


struct LocalDataResult: Codable {
    let documents: [LocalData]
}

struct LocalData: Codable {
    let longitude, latitude: String

    enum CodingKeys: String, CodingKey {
        case longitude = "x"
        case latitude = "y"
    }
}
