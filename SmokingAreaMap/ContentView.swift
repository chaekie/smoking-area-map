//
//  ContentView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/10/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var mapVM = MapViewModel()
    @ObservedObject private var smokingAreaVM = SmokingAreaViewModel()

    @State private var isAppear = false
    @State private var shouldMove = false
    @State private var isLocationAlertPresented = false
    @State private var isPoiInfoPresented = false

    var body: some View {
        MapView(mapVM: mapVM,
                smokingAreaVM: smokingAreaVM,
                isAppear: $isAppear,
                shouldMove: $shouldMove,
                onPoiTapped: onPoiTapped)
        .onAppear() {
            self.isAppear = true
        }
        .onDisappear() {
            self.isAppear = false
        }
        .onReceive(mapVM.$currentLocation) { newLocation in
            if newLocation.latitude == 0.0 && newLocation.latitude == 0.0 {

            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .overlay(alignment: .bottomTrailing) {
            buildPoiSheetView()
            buildCurrentLocationButton()
        }
    }

    private func buildPoiSheetView() -> some View {
        Button("") { }
            .bottomSheet(
                isPresented: $isPoiInfoPresented,
                detents: [.custom(identifier: .customHeight, resolver: { _ in
                    return 150
                })]
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    if let spot = mapVM.selectedSpot {
                        Text("위도: \(spot.latitude), 경도: \(spot.longitude)")
                        Text("주소: \(spot.address)")
                        if let roomType = spot.roomType {
                            Text("개방 형태: \(roomType)")
                        }
                    }
                }
            }
    }

    private func onPoiTapped() {
        if isPoiInfoPresented == false {
            isPoiInfoPresented = true
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
        .alert("위치 서비스 사용", isPresented: $isLocationAlertPresented) {
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
        let isAuthorized = (mapVM.locationServiceAuthorized == .authorizedWhenInUse
                            || mapVM.locationServiceAuthorized == .authorizedAlways)
        shouldMove = isAuthorized
        isLocationAlertPresented = !isAuthorized

        DispatchQueue.main.async {
            shouldMove = false
        }
    }
}

//#Preview {
//    ContentView()
//}
