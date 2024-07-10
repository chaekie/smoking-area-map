//
//  +Bundle.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/10/24.
//

import Foundation

extension Bundle {
    var appName: String {
        guard let name = infoDictionary?["CFBundleName"] as? String else { return "" }
        return name
    }

    var bundleId: String {
        guard let id = bundleIdentifier else { return "" }
        return id
    }

    var versionNumber: String {
        guard let version = infoDictionary?["CFBundleShortVersionString"] as? String else { return "" }
        return version
    }

    var buildNumber: String {
        guard let buildVersion = infoDictionary?["CFBundleVersion"] as? String else { return "" }
        return buildVersion
    }

    var openDataApiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPEN_DATA_PORTAL_KEY") as? String else { return "" }
        return apiKey
    }

    var kakaoRestApiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_REST_API_KEY") as? String else { return "" }
        return apiKey
    }

    var kakaoNativeApiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else { return "" }
        return apiKey
    }
}
