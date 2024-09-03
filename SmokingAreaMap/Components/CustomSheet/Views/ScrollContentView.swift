//
//  ScrollContentView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/22/24.
//

import SwiftUI

struct ScrollContentView: View {
    @ObservedObject var vm: CustomSheetViewModel
    @StateObject var mySpotVM = MySpotViewModel()

    @State private var shouldAlert = false
    @State private var uiImage: UIImage?
    @State private var toast: Toast? = nil
    var collapseSheet: () -> Void

    var body: some View {
            VStack {
                if let spot = vm.spot {
                    buildDragIndicator()

                    if let spot = spot as? SmokingArea {
                        buildSmokingAreaSpotInfo(spot)
                    }

                    if let spot = spot as? MySpot {
                        buildMySpotInfo(spot)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .frame(minHeight: UIScreen.screenSize.height + 1)
            .background(RoundedRectangle(cornerRadius: Constants.BottomSheet.sheetCornerRadius).fill(.white))
            .onReceive(vm.$spot) { newSpot in
                if let spot = newSpot as? MySpot,
                   let photo = spot.photo {
                    uiImage = UIImage(data: photo)
                }
            }
            .toastView(toast: $toast)
    }

    private func buildDragIndicator() -> some View {
        HStack {
            Spacer()
            if !vm.isSheetHeaderVisible {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 65, height: 4)
            }
            Spacer()
        }
        .frame(height: Constants.BottomSheet.dragIndicatorHeight)
    }

    private func buildGoToMySpotDetailButton(_ spot: MySpot) -> some View {
        NavigationLink {
            MySpotDetailView(spot: spot, shouldAlert: $shouldAlert)
                .environmentObject(mySpotVM)
        } label: {
            Text("수정")
        }
    }

    private func buildSmokingAreaSpotInfo(_ spot: SmokingArea) -> some View {
        VStack(spacing: 8) {
            HStack {
                AdaptiveTextView(text: spot.address)
                    .fontStyle(.customPreferredFont(for: .title2, weight: .bold))
                Spacer()
                buildCopyButton(text: spot.address)
            }

            if let roomType = spot.roomType {
                Text("개방 형태: \(roomType)")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func buildCopyButton(text: String) -> some View {
        Button("복사") {
            UIPasteboard.general.string = text
            if UIPasteboard.general.string == text {
                toast = Toast(message: "주소가 복사되었습니다", style: .success)
            } else {
                toast = Toast(message: "복사에 실패했습니다", style: .error)
            }
        }.font(.callout)
    }

    private func buildMySpotInfo(_ spot: MySpot) -> some View {
        VStack(spacing: 8) {
            AdaptiveTextView(text: spot.name)
                .fontStyle(.customPreferredFont(for: .title2, weight: .bold))

            HStack {
                AdaptiveTextView(text: "주소: \(spot.address)")
                    .fontColor(.gray)
                Spacer()
                buildCopyButton(text: spot.address)

            }

            if let uiImage {
                buildPhotoThumbnailView(uiImage)
                    .padding(.vertical)
            }
        }
    }

    private func buildPhotoThumbnailView(_ uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .clipped()
    }
}
