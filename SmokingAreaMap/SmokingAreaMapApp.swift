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
        SDKInitializer.InitSDK(appKey: Bundle.main.kakaoNativeApiKey)
     }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
