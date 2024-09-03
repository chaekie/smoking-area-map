//
//  CustomSheetCoverView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 9/3/24.
//

import SwiftUI

struct CustomSheetCoverView: View {
    @StateObject private var mySpotVM = MySpotViewModel()
    @ObservedObject var vm: CustomSheetViewModel
    @State private var shouldAlert = false

    var body: some View {
        VStack(spacing: 0) {
            buildSafeAreaTopView()
            buildCustomToolbar()
        }
        .frame(maxWidth: .infinity)
        .background(.white)
        .opacity(vm.isSheetHeaderVisible ? 1 : 0)
    }

    private func buildSafeAreaTopView() -> some View {
        HStack {}
            .frame(height: UIScreen.safeAreaInsets.top)
    }

    private func buildCustomToolbar() -> some View {
        HStack {
            buildCloseButton()
            Spacer()
            if let spot = vm.spot as? SmokingArea {
                Text(spot.address)
                Spacer()
            }
            if let spot = vm.spot as? MySpot {
                Text(spot.name)
                Spacer()
                buildGoToMySpotDetailButton(spot)
            }

        }
        .padding(.horizontal)
        .frame(height: Constants.BottomSheet.headerHeight)
    }

    private func buildGoToMySpotDetailButton(_ spot: MySpot) -> some View {
        NavigationLink {
            MySpotDetailView(spot: spot, shouldAlert: $shouldAlert)
                .environmentObject(mySpotVM)
        } label: {
            Text("수정")
        }
    }

    private func buildCloseButton() -> some View {
        Button {
            vm.updateIsSheetHeaderVisibleIfNeeded(condition: false)
            vm.showSmallSheet()
        } label: {
            Image(systemName: "chevron.down")
        }
    }
}
