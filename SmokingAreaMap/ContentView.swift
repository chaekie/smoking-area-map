//
//  ContentView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/10/24.
//

import SwiftUI
import KakaoMapsSDK

struct ContentView: View {
    @State var draw: Bool = false
    @State var coordinator = MapView.KakaoMapCoordinator()
    @StateObject var locationManager = LocationManager()

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

    private func moveToCurrentLocation() {
        let status = UserDefaults.standard.string(forKey: "locationStatus")

        if status == "4" || status == "5" {
            guard let userLongitude = locationManager.lastLocation?.coordinate.longitude,
                  let userLatitude = locationManager.lastLocation?.coordinate.latitude,
                  let controller = coordinator.controller else {
                return
            }

            let view = controller.getView(MapView.mapViewName) as! KakaoMap
            let cameraUpdate = CameraUpdate.make(
                target: MapPoint(longitude: userLongitude, latitude: userLatitude),
                zoomLevel: 17,
                rotation: 0.0,
                tilt: 0.0,
                mapView: view
            )

            view.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 500))
        } else {
            isUnauthorized = true
        }
    }
}

#Preview {
    ContentView()
}
