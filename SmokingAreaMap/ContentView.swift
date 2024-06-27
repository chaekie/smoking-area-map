//
//  ContentView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/10/24.
//

import SwiftUI
//import Combine

struct ContentView: View {
    @StateObject private var viewModel = MapViewModel()
    @ObservedObject private var smokingAreaManager = SmokingAreaManager()

    @State private var isAppear = false
    @State private var shouldMove = false
    @State private var isLocationAlertPresented = false
    @State private var isPoiInfoPresented = false

    var body: some View {
            MapView(viewModel: viewModel,
                    smokingAreaMananger: smokingAreaManager,
                    isAppear: $isAppear,
                    shouldMove: $shouldMove,
                    onPoiTapped: onPoiTapped)
            .onAppear() {
                self.isAppear = true
                Task {
                    await smokingAreaManager.fetchSmokingArea(page: 1)
                }
            }
            .onDisappear() {
                self.isAppear = false
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(alignment: .bottomTrailing) {
                buildPoi()
                buildCurrentLocationButton()
            }
    }

    private func buildPoi() -> some View {
        Button("") { }
            .sheet(isPresented: $isPoiInfoPresented) {
                VStack(alignment: .leading, spacing: 8) {
                    if let spot = viewModel.selectedSpot {
                        Text("위도: \(spot.latitude), 경도: \(spot.longitude)")
                        Text("주소: \(spot.district) \(spot.address)")
                        Text("실내외 구분: \(spot.space)")
                        Text("개방 형태: \(spot.roomType)")
                    }
                }.presentationDetents([.height(150)])
            }
    }

    private func onPoiTapped() {
        isPoiInfoPresented = true
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
        let isAuthorized = viewModel.locationServiceAuthorized == .authorizedWhenInUse || viewModel.locationServiceAuthorized == .authorizedAlways
        shouldMove = isAuthorized
        isLocationAlertPresented = !isAuthorized

        DispatchQueue.main.async {
            shouldMove = false
        }
    }
}

#Preview {
    ContentView()
}

