//
//  SmokingAreaMapApp.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/10/24.
//

import SwiftUI
import KakaoMapsSDK

@main
struct SmokingAreaMapApp: App {

    init() {
        guard let infoDic = Bundle.main.infoDictionary else { return }
        if let kakaoKey = infoDic["KAKAO_NATIVE_APP_KEY"] as? String {
            SDKInitializer.InitSDK(appKey: kakaoKey)
        }
     }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
