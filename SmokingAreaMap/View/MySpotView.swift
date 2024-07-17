//
//  MySpotView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/16/24.
//

import SwiftUI

struct MySpotView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: MySpotViewModel
    @State var isNew = false
    
    @Binding var isCreated: Bool?

    init(spot: Spot? = nil, isCreated: Binding<Bool?> = .constant(nil)) {
        if spot == nil { isNew = true }
        self._vm = StateObject(wrappedValue: MySpotViewModel(spot))
        self._isCreated = isCreated
    }

    var body: some View {
        VStack {
            if isNew { buildSheetToolbar() }
            List {
                Section {
                    TextField("장소명", text: $vm.name)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("주소", text: $vm.address)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                if !isNew { buildDeleteSpotButton() }
            }
        }
        .toolbar {
            buildToolbar()
        }
    }

    func buildSheetToolbar() -> some View {
        HStack {
            Button("취소") {
                dismiss()
            }
            Spacer()
            Button("저장") {
                vm.createSpot()
                isCreated = true
                dismiss()
            }
            .disabled(!vm.isSaveButtonEnabled)
        }
        .padding(.horizontal)
        .padding(.top)
    }

    func buildDeleteSpotButton() -> some View {
        Button("장소 삭제하기", role: .destructive) {
            if let spot = vm.spot {
                vm.deleteSpot(spot)
                dismiss()
            }
        }
    }

    @ToolbarContentBuilder
    func buildToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("저장") {
                if let spot = vm.spot {
                    vm.updateSpot(spot)
                    dismiss()
                }
            }
            .disabled(!vm.isSaveButtonEnabled)
        }
    }
}

#Preview {
    MySpotView()
}
