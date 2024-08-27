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
        ZStack(alignment: .top) {
            NavigationStack {
                MapRepresentableView(isAppear: $isAppear,
                                     shouldMove: $shouldMove,
                                     hasDistirctInfo: hasDistirctInfo)
                .onAppear() {
                    self.isAppear = true
                    smokingAreaVM.getAllSpot()
                }
                .onDisappear() {
                    self.isAppear = false
                }
                .onReceive(mapVM.$oldDistrictValue) { value in
                    if value != nil {
                        hasDistirctInfo = true
                    }
                }
                .onReceive(mapVM.$selectedSpot) { newSpot in
                    presentSheet(oldSpot: mapVM.selectedSpot, newSpot: newSpot)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .overlay(alignment: .bottomTrailing) {
                    CurrentLocationButton(shouldMove: $shouldMove,
                                          isLocationAlertPresented: $isLocationAlertPresented)
                }
                .overlay(alignment: .top) {
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
                .toolbar {
                    NavigationLink(destination: MySpotListView()) {
                        Label("내 장소 보기", systemImage: "list.bullet")
                    }
                }
            }
            CustomSheetView(vm: sheetVM, isPresented: $isSpotModalPresented)
            buildSafeAreaTopForCustomSheet()

        }
        .environmentObject(mapVM)
        .environmentObject(smokingAreaVM)
    }

    func presentSheet(oldSpot: SpotPoi?, newSpot: SpotPoi?) {
        if (oldSpot == nil && newSpot != nil) { isSpotModalPresented = true }
        else if newSpot == nil { isSpotModalPresented = false }
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
                        .shadow(color: .black.opacity(0.2), radius: 5)
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
                        .shadow(color: .black.opacity(0.2), radius: 5)
                )
        }
        .disabled(smokingAreaVM.page == totalPage || smokingAreaVM.totalCount == 0)
    }

    private func buildSafeAreaTopForCustomSheet() -> some View {
        HStack {}
            .frame(height: 0)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .background(.white)
            .offset(y: sheetVM.currentDetent == .large ? 0 : -UIScreen.safeAreaInsets.top)
    }
}
