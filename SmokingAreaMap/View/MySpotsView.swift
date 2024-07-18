//
//  MySpotsView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/15/24.
//

import SwiftUI

struct MySpotsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = MySpotsViewModel()
    @State private var isPresented = false
    @State private var isCreatingNew: Bool? = nil

    var body: some View {
            VStack {
                if isCreatingNew == true {
                    fullScreenProgressView()
                } else if vm.spots.isEmpty {
                    emptySpotView()
                } else {
                    List(vm.spots, id: \.id) { spot in
                        NavigationLink(
                            destination: DeferView(MySpotView(spot: spot))
                        ) {
                            buildSpotRow(spot)
                        }
                    }
                }
            }
            .navigationTitle("내 장소 보기")
            .onAppear() {
                vm.getAllSpot()
            }
            .toolbar {
                Button {
                    isPresented = true
                } label: {
                    Label("내 장소 만들기", systemImage: "plus")
                }
            }
            .sheet(isPresented: $isPresented, onDismiss: {
                if isCreatingNew != nil {
                    vm.getAllSpot()
                }
                isCreatingNew = nil
            }) {
                MySpotView(isCreatingNew: $isCreatingNew)
            }
    }

    func emptySpotView() -> some View {
        CenterContainerView {
            Text("등록된 내 장소가 없습니다.\n+ 버튼을 눌러 나만의 흡연구역을 등록하세요.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .font(.callout)
        }
    }

    func fullScreenProgressView() -> some View {
        CenterContainerView {
            ProgressView()
        }
    }

    func buildSpotRow(_ spot: MySpot) -> some View {
        HStack {
            VStack {
                Text(spot.name)
                Text(spot.address)
            }
            Spacer()
        }
    }
}

struct CenterContainerView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                content
                Spacer()
            }
            Spacer()
        }
        .background(Color(UIColor.secondarySystemBackground))
    }
}

#Preview {
    MySpotsView()
}
