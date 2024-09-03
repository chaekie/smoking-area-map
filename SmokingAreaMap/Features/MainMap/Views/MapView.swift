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
    @StateObject private var sheetVM = CustomSheetViewModel()

    @State private var isAppear = false
    @State private var hasDistirctInfo = false
    @State private var shouldMove = false
    @State private var isLocationAlertPresented = false
    @State private var isSpotModalPresented = false
    @State private var showMySpotListView = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                MapRepresentableView(isAppear: $isAppear,
                                     shouldMove: $shouldMove,
                                     hasDistirctInfo: hasDistirctInfo)
                .onAppear() {
                    self.isAppear = true
                    smokingAreaVM.getAllSpot()
                }
                .onDisappear() {
                    self.isAppear = false
                    sheetVM.updateIsSheetHeaderVisibleIfNeeded(condition: false)
                }
                .onReceive(mapVM.$oldDistrictValue) { value in
                    if value != nil {
                        hasDistirctInfo = true
                    }
                }
                .onReceive(smokingAreaVM.$selectedSpot) { newSpot in
                    presentSheet(oldSpot: smokingAreaVM.selectedSpot, newSpot: newSpot)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .overlay(alignment: .bottomTrailing) {
                    CurrentLocationButton(shouldMove: $shouldMove,
                                          isLocationAlertPresented: $isLocationAlertPresented)
                }

                CustomSheetCoverView(vm: sheetVM)
                CustomSheetView(vm: sheetVM, isPresented: $isSpotModalPresented)
            }
            .ignoresSafeArea()
            .toolbar {
                buildSearchOrLoadButtonOrAlertText()
                buildGoToMySpotListButton()
            }
        }
        .environmentObject(mapVM)
        .environmentObject(smokingAreaVM)
    }

    private func presentSheet(oldSpot: SpotPoi?, newSpot: SpotPoi?) {
        if (oldSpot == nil && newSpot != nil) { isSpotModalPresented = true }
        else if newSpot == nil { isSpotModalPresented = false }
        sheetVM.spot = newSpot
    }

    private func buildGoToMySpotListButton() -> some View {
        Button {
            isSpotModalPresented = false
            showMySpotListView = true
        } label: {
            Label("내 장소 보기", systemImage: "list.bullet")
        }.navigationDestination(isPresented: $showMySpotListView) {
            MySpotListView()
        }
    }

    @ViewBuilder
    private func buildSearchOrLoadButtonOrAlertText() -> some View {
        if let oldDistrictValue = mapVM.oldDistrictValue,
           let newDistrictValue = mapVM.newDistrictValue {
            if !smokingAreaVM.isInSeoul {
                buildOutOfSeoulText()
            } else if newDistrictValue.name == oldDistrictValue.name {
                buildLoadMoreButton(newDistrictValue)
            } else {
                buildSearchHereButton(newDistrictValue)
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

    private func buildSearchHereButton(_ district: DistrictInfo) -> some View {
        Button {
            Task {
                smokingAreaVM.page = 1
                await smokingAreaVM.fetchSmokingArea(district: district)
                mapVM.oldDistrictValue = district
            }
        } label: {
            Text("\(district.name) 검색")
                .font(.callout)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .frame(minWidth: 115)
                .background(
                    Capsule()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.2), radius: 3)
                )
        }
    }

    private func buildLoadMoreButton(_ district: DistrictInfo) -> some View {
        let totalPage = Int(ceil(Double(smokingAreaVM.totalCount)/Double(smokingAreaVM.size)))

        return Button {
            Task {
                smokingAreaVM.page += 1
                await smokingAreaVM.fetchSmokingArea(district: district)
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
                        .shadow(color: .black.opacity(0.2), radius: 3)
                )
        }
        .disabled(smokingAreaVM.page == totalPage || smokingAreaVM.totalCount == 0)
    }
}
