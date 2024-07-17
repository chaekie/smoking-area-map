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
    @State private var isCreated: Bool? = nil

    var body: some View {
        NavigationStack {
            List(vm.spots, id: \.id) { spot in
                NavigationLink(
                    destination: DeferView(MySpotView(spot: spot))
                ) {
                    buildSpotRow(spot)
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
                if isCreated != nil {
                    vm.getAllSpot()
                }
                isCreated = nil
            }) {
                MySpotView(isCreated: $isCreated)
            }
        }

    }

    func buildSpotRow(_ spot: Spot) -> some View {
        HStack {
            VStack {
                Text(spot.name ?? "")
                Text(spot.address ?? "")
            }
            Spacer()
        }
    }
}

#Preview {
    MySpotsView()
}
