//
//  SubMapView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/22/24.
//

import SwiftUI

struct SubMapView: View {
    @EnvironmentObject var mySpotVM: MySpotViewModel
    @Binding var isPresented: Bool
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
        .overlay(alignment: .topLeading) {
            if mapMode == .searching { buildHeaderView() }
        }
        .overlay(alignment: .bottom) {
            if mapMode == .searching { buildFooterView() }
        }
        .overlay(alignment: .center) {
            switch mapMode {
            case .searching:
                Image(systemName: "dot.circle.viewfinder")
                    .foregroundStyle(.blue)
                    .font(.title2)
            case .showing:
                Image("my_pin")
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if mapMode == .searching {
                CurrentLocationButtonView(shouldMove: $shouldMove, 
                                          isLocationAlertPresented: $isLocationAlertPresented)
            }
        }
    }

    private func buildHeaderView() -> some View {
        HStack {
            Button("취소") { isPresented = false }
            Spacer()
            Button("저장") {
                mySpotVM.setLocation()
                isPresented = false
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
