//
//  District.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/5/24.
//

import Foundation

struct DistrictInfo: Codable, Equatable {
    var name: String
    var code: String
    var uuid: String

    init(name: String, code: String, uuid: String) {
        self.name = name
        self.code = code
        self.uuid = uuid
    }
}

enum District: String, CaseIterable, Codable {
    case gangnamGu = "강남구"
    case gangdongGu = "강동구"
    case gangbukGu = "강북구"
    case gangseoGu = "강서구"
    case guroGu = "구로구"
    case gwanakGu = "관악구"
    case gwangjinGu = "광진구"
    case geumcheonGu = "금천구"
    case nowonGu = "노원구"
    case mapoGu = "마포구"
    case eunpyeongGu = "은평구"
    case dongdaemunGu = "동대문구"
    case dobongGu = "도봉구"
    case dongjakGu = "동작구"
    case seochoGu = "서초구"
    case seodaemunGu = "서대문구"
    case seongdongGu = "성동구"
    case seongbukGu = "성북구"
    case songpaGu = "송파구"
    case yeongdeungpoGu = "영등포구"
    case yongsanGu = "용산구"
    case yangcheonGu = "양천구"
    case jongnoGu = "종로구"
    case jungGu = "중구"
    case jungnangGu = "중랑구"

    static let defaultValue: District = .jungGu

    var name: String {
        switch self {
        case .gangnamGu: return self.rawValue
        case .gangdongGu: return self.rawValue
        case .gangbukGu: return self.rawValue
        case .gangseoGu: return self.rawValue
        case .guroGu: return self.rawValue
        case .gwanakGu: return self.rawValue
        case .gwangjinGu: return self.rawValue
        case .geumcheonGu: return self.rawValue
        case .nowonGu: return self.rawValue
        case .mapoGu: return self.rawValue
        case .eunpyeongGu: return self.rawValue
        case .dongdaemunGu: return self.rawValue
        case .dobongGu: return self.rawValue
        case .dongjakGu: return self.rawValue
        case .seochoGu: return self.rawValue
        case .seodaemunGu: return self.rawValue
        case .seongdongGu: return self.rawValue
        case .seongbukGu: return self.rawValue
        case .songpaGu: return self.rawValue
        case .yeongdeungpoGu: return self.rawValue
        case .yongsanGu: return self.rawValue
        case .yangcheonGu: return self.rawValue
        case .jongnoGu: return self.rawValue
        case .jungGu: return self.rawValue
        case .jungnangGu: return self.rawValue
        }
    }

    var code: String {
        switch self {
        case .gangnamGu: return ""
        case .gangdongGu: return ""
        case .gangbukGu: return "15049030"
        case .gangseoGu: return "15068987"
        case .guroGu: return "15069274"
        case .gwanakGu: return "15040591"
        case .gwangjinGu: return "15040615"
        case .geumcheonGu: return ""
        case .nowonGu: return "15078097"
        case .mapoGu: return ""
        case .eunpyeongGu: return ""
        case .dongdaemunGu: return "15070168"
        case .dobongGu: return ""
        case .dongjakGu: return "15049031"
        case .seochoGu: return "" //15074379
        case .seodaemunGu: return "15040413"
        case .seongdongGu: return "15029169"
        case .seongbukGu: return "15100203"
        case .songpaGu: return "15090343"
        case .yeongdeungpoGu: return "15069051"
        case .yongsanGu: return "15073796"
        case .yangcheonGu: return "15040511"
        case .jongnoGu: return ""
        case .jungGu: return "15080296"
        case .jungnangGu: return "15040636"
        }
    }
    
    var uuid: String {
        switch self {
        case .gangnamGu: return ""
        case .gangdongGu: return ""
        case .gangbukGu: return "0d7a603a-608e-481a-8ff0-a4cd23d7c449"
        case .gangseoGu: return "92996e84-3919-4fc6-a751-a57aaf48f0f3"
        case .guroGu: return "e4f910f0-cad9-440b-9fa8-bf3fd0b0b499"
        case .gwanakGu: return "b43f416d-1446-44b3-90e5-86589950e8cc"
        case .gwangjinGu: return "d494c578-f45e-4c42-9dde-c277cbd8717a"
        case .geumcheonGu: return ""
        case .nowonGu: return "d024d11e-1b17-4f65-b5b3-fb2a840d43c3"
        case .mapoGu: return ""
        case .eunpyeongGu: return ""
        case .dongdaemunGu: return "aef69bb4-d848-4088-9abd-f6e3dd361cfb"
        case .dobongGu: return ""
        case .dongjakGu: return "03e47093-48b5-442c-a6a5-bd756148f6ae"
        case .seochoGu: return "" // 16735cd3-6305-4539-b0b4-e92ad6653ec7
        case .seodaemunGu: return "280fb8c7-7bd8-4633-896e-99a76d23d2de"
        case .seongdongGu: return "68c14d9d-6a3c-4cd6-9199-959ef803e3f3_201908021643"
        case .seongbukGu: return "b3a63072-4c2c-4f49-ba75-cd9ecb4ce0d7"
        case .songpaGu: return "7f5d9c71-fdc4-4a83-8c60-fa980eb70465"
        case .yeongdeungpoGu: return "51a46754-1f5c-4490-aefa-a86d8c92cebf"
        case .yongsanGu: return "17fbd06c-45bb-48aa-9be7-b26dbc708c9c"
        case .yangcheonGu: return "4107a841-693b-45d2-91c9-89a28222988a"
        case .jongnoGu: return ""
        case .jungGu: return "ea9e4970-741d-433b-9f60-de9dc0f2a9c5"
        case .jungnangGu: return "dc7ed6ee-001f-4312-a75a-ed408fd01f62"
        }
    }
}


