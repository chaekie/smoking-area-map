//
//  ErrorKind.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/25/24.
//

import Foundation

struct SAError: Error {
    let kind: ErrorKind
    let title: String
    let description: String

    init(_ errorKind: ErrorKind) {
        title = errorKind.title
        description = errorKind.description
        kind = errorKind
    }

    init(_ errorKind: ErrorKind, description: String) {
        title = errorKind.title
        self.description = description
        kind = errorKind
    }
}

enum ErrorKind: String {
    case networkUnavailable
    case invalidResponse

    case jsonDecodingFailed
    case invalidUrl

    case wrongParameter
    case wrongApiKey
    case unauthorizedApiKey
    case quotaExceeded

    case serverError
    case unknownError

    var title: String {
        switch self {
        case .networkUnavailable:
            return "네트워크 문제"
        case .invalidResponse:
            return "잘못된 응답"
        case .jsonDecodingFailed, .invalidUrl:
            return "데이터 처리 문제"
        case .wrongParameter, .wrongApiKey, .unauthorizedApiKey:
            return "인증 오류"
        case .quotaExceeded:
            return "사용 쿼터 초과"
        case .serverError:
            return "서버 문제"
        case .unknownError:
            return "알 수 없는 오류"
        }
    }

    var description: String {
        switch self {
        case .networkUnavailable:
            return "네트워크가 불안정합니다."
        case .invalidResponse:
            return "유효하지 않은 응답입니다."
        case .jsonDecodingFailed:
            return "JSON 데이터를 디코딩하는 데 실패했습니다."
        case .invalidUrl:
            return "잘못된 URL입니다."
        case .wrongParameter:
            return "잘못된 API 인증 파라미터입니다."
        case .wrongApiKey:
            return "잘못된 API 키입니다."
        case .unauthorizedApiKey:
            return "API 인증 권한이 없습니다."
        case .quotaExceeded:
            return "API 사용 쿼터를 초과하였습니다."
        case .serverError:
            return "서버에 문제가 발생하였습니다."
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
