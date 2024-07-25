//
//  SubMapView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/22/24.
//

import SwiftUI

struct SubMapView: View {
    @EnvironmentObject var mySpotVM: MySpotDetailViewModel
    @Environment(\.presentationMode) var isPresented
    let mapMode: MapMode

    @State private var isAppear = false
    @State private var shouldMove = false
    @State private var isLocationAlertPresented = false

    var body: some View {
        SubMapRepresentableView(
            isAppear: $isAppear,
            shouldMove: $shouldMove,
            mapMode: mapMode
        )
        .onAppear() {
            self.isAppear = true
        }
        .onDisappear() {
            self.isAppear = false
        }
        .ignoresSafeArea()
        .allowsHitTesting(mapMode == .searching)
        .frame(maxWidth: .infinity, maxHeight: mapMode.height)
        .if(mapMode == .showing) {
            $0.overlay(alignment: .center) {
                Image("my_pin")
            }
        }
        .if(mapMode == .searching) {
            $0.overlay(alignment: .topLeading) {
                buildHeaderView()
            }
            .overlay(alignment: .bottom) {
                buildFooterView()
            }
            .overlay(alignment: .bottomTrailing) {
                CurrentLocationButton(shouldMove: $shouldMove,
                                          isLocationAlertPresented: $isLocationAlertPresented)
            }
            .overlay(alignment: .center) {
                Image(systemName: "dot.circle.viewfinder")
                    .foregroundStyle(.blue)
                    .font(.title2)
            }
        }
    }

    private func buildHeaderView() -> some View {
        HStack {
            Button("취소") { isPresented.wrappedValue.dismiss() }
            Spacer()
            Button("저장") {
                mySpotVM.setLocation()
                isPresented.wrappedValue.dismiss()
            }
        }
        .padding()
        .background(.regularMaterial)
    }

    private func buildFooterView() -> some View {
        HStack {
            Text(mySpotVM.tempAddress)
            Spacer()
        }
        .padding()
        .background(.regularMaterial)
    }
}
