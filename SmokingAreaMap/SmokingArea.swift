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
    let type: String
    let location: String

    private enum CodingKeys : String, CodingKey {
        case district = "자치구"
        case address = "시설 구분"
        case longitude = "경도"
        case latitude = "위도"
        case type = "시설형태"
        case location = "설치 위치"
    }
}

struct SmokingArea: Codable {
    let district: district
    let address: String
    let longitude: String
    let latitude: String
    let type: type
    let location: location
    
    enum location: String, Codable {
        case 미정 = "미정"
        case 실외 = "실외"
    }

    enum type: String, Codable {
        case 미정 = "미정"
        case 개방형 = "개방형"
        case 완전개방형 = "완전개방형"
    }

    enum district: String, Codable {
        case 서울 = "서울"
        case 영등포구 = "영등포구"
    }
}


