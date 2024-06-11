//
//  AppDelegate.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/11/24.
//

import UIKit
import KakaoMapsSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    private let env = ProcessInfo.processInfo.environment

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let kakaoKey = env["KAKAO_NATIVE_APP_KEY"] {
            SDKInitializer.InitSDK(appKey: kakaoKey)
        }
        return true
    }

}
