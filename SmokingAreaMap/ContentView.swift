//
//  ContentView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/10/24.
//

import KakaoMapsSDK
import SwiftUI

struct ContentView: View {
    @StateObject private var manager = LocationManager()

    @State private var isAppear = false
    @State private var shouldMove = false
    @State private var isPresented = false

    var body: some View {
        MapView(isAppear: $isAppear, shouldMove: $shouldMove)
            .onAppear() {
                self.isAppear = true
            }
            .onDisappear() {
                self.isAppear = false
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(alignment: .bottomTrailing) {
                buildCurrentLocationButton()
            }
    }

    private func buildCurrentLocationButton() -> some View {
        Button {
            moveToCurrentLocation()
        } label: {
            Image(systemName: "dot.scope")
                .font(.title)
                .padding(10)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 5)
                .padding([.bottom, .trailing], 20)
        }
        .alert("위치 서비스 사용", isPresented: $isPresented) {
            Button("취소", role: .cancel) {}
            Button("설정으로 이동") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return
                }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("위치 서비스를 사용할 수 없습니다.\n기기의 \"설정 > 앱이름 > 위치\"에서\n위치 서비스를 켜주세요.")
        }
    }

    private func moveToCurrentLocation() {
        let isAuthorized = manager.locationServiceAuthorized == .authorizedWhenInUse || manager.locationServiceAuthorized == .authorizedAlways
        shouldMove = isAuthorized
        isPresented = !isAuthorized

        DispatchQueue.main.async {
            shouldMove = false
        }
    }
}

#Preview {
    ContentView()
}

