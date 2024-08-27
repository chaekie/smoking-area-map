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
        VStack(spacing: 10) {
            Spacer().frame(height: 20)
            Button {
                vm.showSmallSheet()
            } label: {
                Text("닫기")
            }
            
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
                        if let uiImage {
                            Text("사진")
                            buildPhotoThumbnailView(uiImage)
                        }

                        NavigationLink {
                            MySpotDetailView(spot: spot, shouldAlert: $shouldAlert)
                                .environmentObject(mySpotVM)
                        } label: {
                            Text("수정하러 가기")
                        }
                    }
                }
            }
            Spacer()
        }
        .onReceive(mapVM.$selectedSpot) { spot in
            if let spot = spot as? MySpot,
               let photo = spot.photo {
                uiImage = UIImage(data: photo)
            }
        }
        .padding(.horizontal)
        .frame(minHeight: vm.screenHeight * 2)
        .onDisappear() {
            mapVM.selectedSpot = nil
        }
    }

    private func buildPhotoThumbnailView(_ uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .clipped()
    }
}
