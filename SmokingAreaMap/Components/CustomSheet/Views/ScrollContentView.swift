//
//  ScrollContentView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/22/24.
//

import SwiftUI

struct ScrollContentView: View {
    @EnvironmentObject var mapVM: MapViewModel
    @ObservedObject var vm: CustomSheetViewModel
    @StateObject var mySpotVM = MySpotViewModel()

    @State private var shouldAlert = false
    @State private var uiImage: UIImage?
    var collapseSheet: () -> Void

    var body: some View {
        VStack {
            if let spot = mapVM.selectedSpot {
                if vm.currentDetent == .large {
                    buildCustomToolbar()
                } else {
                    if let spot = spot as? MySpot,
                       let _ = spot.photo {
                        buildDragIndicator()
                    } else {
                        Spacer().frame(height: 20)
                    }
                }

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
        .frame(minHeight: UIScreen.screenSize.height / 2)
        .onReceive(mapVM.$selectedSpot) { spot in
            if let spot = spot as? MySpot,
               let photo = spot.photo {
                uiImage = UIImage(data: photo)
            }
        }
    }

    private func buildDragIndicator() -> some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 65, height: 6)
            Spacer()
        }
        .frame(height: 20)
    }

    private func buildCustomToolbar() -> some View {
        HStack {
            buildCloseButton()
            Spacer()
            if let spot = mapVM.selectedSpot as? MySpot {
                buildGoToMySpotDetailButton(spot)
            }
        }
        .frame(height: 48)
    }

    private func buildCloseButton() -> some View {
        Button {
            vm.showSmallSheet()
        } label: {
            Image(systemName: "chevron.down")
        }
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

                Button("복사") {
                    UIPasteboard.general.string = spot.address
                }.font(.callout)
            }

            if let roomType = spot.roomType {
                Text("개방 형태: \(roomType)")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func buildMySpotInfo(_ spot: MySpot) -> some View {
        VStack(spacing: 8) {
            AdaptiveTextView(text: spot.name)
                .fontStyle(.customPreferredFont(for: .title2, weight: .bold))

            AdaptiveTextView(text: "주소: \(spot.address)")
                .fontColor(.gray)

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
