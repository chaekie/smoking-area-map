//
//  ContentView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/10/24.
//

import KakaoMapsSDK
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager

    @State var draw: Bool = false
    @State var coordinator = MapView.KakaoMapCoordinator()
    @State private var isUnauthorized = false

    var body: some View {
        MapView(draw: $draw, coordinator: $coordinator)
            .onAppear(perform: {
                self.draw = true
            })
            .onDisappear(perform: {
                self.draw = false
            })
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
        .alert("위치 서비스 사용", isPresented: $isUnauthorized) {
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

    func moveToCurrentLocation() {
        let status = UserDefaults.standard.string(forKey: "locationStatus")

        guard let controller = coordinator.controller,
              let view = controller.getView(MapView.mapViewName) as? KakaoMap,
              let status = status else { return }

        isUnauthorized = !locationManager.shouldMoveToCurrentLocation(view: view, status: status)
    }
}

#Preview {
    ContentView()
        .environmentObject({() -> LocationManager in
            let envObj = LocationManager()
            return envObj
        }() )
}
