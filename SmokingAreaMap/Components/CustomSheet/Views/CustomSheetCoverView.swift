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
        .opacity(vm.isSheetCoverVisible ? 1 : 0)
    }

    private func buildSafeAreaTopView() -> some View {
        HStack {}
            .frame(height: UIScreen.safeAreaInsets.top)
    }

    private func buildCustomToolbar() -> some View {
        var title = ""
        if let spot = vm.spot as? MySpot {
            title = spot.name
        } else if let spot = vm.spot as? SmokingArea {
            title = spot.address
        }

        return ZStack {
            if vm.isTitleVisible {
                Text(title)
                    .bold()
                    .padding(.horizontal, 50)
                    .lineLimit(1)
            }
            HStack {
                buildCloseButton()
                Spacer()
                if let spot = vm.spot as? MySpot {
                    buildGoToMySpotDetailButton(spot)
                }
            }
        }
        .frame(height: Constants.BottomSheet.headerHeight)
        .padding(.horizontal)

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
            vm.updateVisibilityIfNeeded(currentValue: &vm.isSheetCoverVisible, newValue: false)
            vm.showSheet(detent: .small)
        } label: {
            Image(systemName: "chevron.down")
        }
    }
}
