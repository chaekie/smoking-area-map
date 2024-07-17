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
    @State private var isPoiModalPresented = false

    @State private var isMyAreaPresented = false

    var body: some View {
        NavigationStack {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(alignment: .bottomTrailing) {
                buildPoiSheetView()
                buildCurrentLocationButton()
            }
            .overlay(alignment: .top) {
                if mapVM.oldDistrictValue.name.isEmpty {
                    EmptyView()
                } else if !smokingAreaVM.isInSeoul {
                    buildOutOfSeoulText()
                } else if mapVM.newDistrictValue.name == mapVM.oldDistrictValue.name {
                    buildLoadMoreButton()
                } else {
                    buildSearchHereButton()
                }
            }
            .toolbar {
                NavigationLink(destination: MySpotsView()) {
                    Label("내 장소 보기", systemImage: "list.bullet")
                }
            }
        }

    }

    private func buildOutOfSeoulText() -> some View {
        Text("서울을 벗어났습니다")
            .bold()
            .foregroundStyle(.red)
            .opacity(0.8)
            .font(.callout)
            .padding(.vertical, 8)
    }

    private func buildSearchHereButton() -> some View {
        Button {
            Task {
                smokingAreaVM.page = 1
                await smokingAreaVM.fetchSmokingArea(district: mapVM.newDistrictValue)
                mapVM.oldDistrictValue = mapVM.newDistrictValue
            }
        } label: {
            Text("\(mapVM.newDistrictValue.name) 검색")
                .font(.callout)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .frame(minWidth: 115)
                .background(
                    Capsule()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.2), radius: 5)
                )
        }
    }

    private func buildLoadMoreButton() -> some View {
        let totalPage = Int(ceil(Double(smokingAreaVM.totalCount)/Double(smokingAreaVM.size)))

        return Button {
            Task {
                smokingAreaVM.page += 1
                await smokingAreaVM.fetchSmokingArea(district: mapVM.newDistrictValue)
            }
        } label: {
            Text("결과 더보기 \(smokingAreaVM.page)/ \(totalPage)")
                .font(.callout)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .frame(minWidth: 115)
                .background(
                    Capsule()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.2), radius: 5)
                )
        }
        .disabled(smokingAreaVM.page == totalPage || smokingAreaVM.totalCount == 0)
    }

    private func buildPoiSheetView() -> some View {
        Button("") { }
            .bottomSheet(
                isPresented: $isPoiModalPresented,
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
                .padding(.horizontal)
            }
    }

    private func onPoiTapped() {
        if isPoiModalPresented == false {
            isPoiModalPresented = true
        }
    }

    private func buildCurrentLocationButton() -> some View {
        Button {
            moveToCurrentLocation()
        } label: {
            Image(systemName: "dot.scope")
                .font(.title2)
                .padding(15)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 5)
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
            Text("위치 서비스를 사용할 수 없습니다.\n기기의 \"설정 > \(Bundle.main.appName) > 위치\"에서\n위치 서비스를 켜주세요.")
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
