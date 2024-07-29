//
//  MySpotListView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/15/24.
//

import SwiftUI

struct MySpotListView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var mySpotVM = MySpotViewModel()
    @State private var isPresented = false
    @State private var shouldAlert = false

    var body: some View {
        VStack {
            if mySpotVM.isCreating {
                fullScreenProgressView()
            } else if mySpotVM.spots.isEmpty {
                emptySpotView()
            } else {
                List(mySpotVM.spots, id: \.id) { spot in
                    NavigationLink {
                        DeferView(MySpotDetailView(spot: spot,
                                                   shouldAlert: $shouldAlert))
                        .environmentObject(mySpotVM)
                    } label: {
                        buildSpotRow(spot)
                    }
                }
            }
        }
        .navigationTitle("내 장소 보기")
        .onAppear() {
            mySpotVM.getAllSpot()
        }
        .toolbar {
            Button {
                isPresented = true
            } label: {
                Label("내 장소 만들기", systemImage: "plus")
            }
        }
        .sheet(isPresented: $isPresented) {
            MySpotDetailView(isPresented: $isPresented,
                             shouldAlert: $shouldAlert)
            .environmentObject(mySpotVM)
        }
    }

    private func emptySpotView() -> some View {
        CenterContainerView {
            Text("등록된 내 장소가 없습니다.\n+ 버튼을 눌러 나만의 흡연구역을 등록하세요.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .font(.callout)
        }
    }

    private func fullScreenProgressView() -> some View {
        CenterContainerView {
            ProgressView()
        }
    }

    private func buildSpotRow(_ spot: MySpot) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(spot.name)
                Text(spot.address)
            }
            Spacer()
        }
    }
}

#Preview {
    MySpotListView()
}
