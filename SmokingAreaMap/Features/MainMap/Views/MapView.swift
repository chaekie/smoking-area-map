//
//  ContentView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/10/24.
//

import SwiftUI

struct MapView: View {
    @StateObject private var mapVM = MapViewModel()
    @StateObject private var smokingAreaVM = SmokingAreaViewModel()

    @State private var isAppear = false
    @State private var shouldMove = false
    @State private var isLocationAlertPresented = false
    @State private var isPoiModalPresented = false

    var body: some View {
        NavigationStack {
            MapRepresentableView(isAppear: $isAppear,
                                 shouldMove: $shouldMove,
                                 onPoiTapped: onPoiTapped)
            .onAppear() {
                self.isAppear = true
                smokingAreaVM.getAllSpot()
            }
            .onDisappear() {
                self.isAppear = false
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(alignment: .bottomTrailing) {
                buildPoiSheetView()
                CurrentLocationButton(shouldMove: $shouldMove,
                                      isLocationAlertPresented: $isLocationAlertPresented)
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
                NavigationLink(destination: MySpotListView()) {
                    Label("내 장소 보기", systemImage: "list.bullet")
                }
            }
        }
        .environmentObject(mapVM)
        .environmentObject(smokingAreaVM)
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

                        if let spot = spot as? SmokingArea {
                            if let roomType = spot.roomType {
                                Text("개방 형태: \(roomType)")
                            }
                        }

                        if let spot = spot as? MySpot {
                            Text("장소명: \(spot.name)")
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
}
