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
    @State var isEditingMode = false
    @State var shouldDelete = false

    @FocusState var isAddressFocused
    @FocusState var isLongitudeFocused
    @FocusState var isLatitudeFocused

    @Binding var isCreatingNew: Bool?

    init(spot: MySpot? = nil, isCreatingNew: Binding<Bool?> = .constant(nil)) {
        if spot == nil { isNew = true }
        self._vm = StateObject(wrappedValue: MySpotViewModel(spot))
        self._isCreatingNew = isCreatingNew
    }

    var body: some View {
        VStack(spacing: 0) {
            if isNew { buildSheetToolbar() }
            if !isNew { buildCreatedDateView() }

            List {
                if isNew || isEditingMode {
                    buildInputView()
                } else {
                    buildOutputView()
                }
                if !isNew { buildDeleteSpotButton() }
            }
        }
        .toolbar {
            buildToolbar()
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationBarBackButtonHidden(isEditingMode)
    }

    func buildSheetToolbar() -> some View {
        HStack {
            Button("취소") {
                dismiss()
            }
            Spacer()
            Button("저장") {
                vm.createSpot()
                isCreatingNew = true
                dismiss()
            }
            .disabled(!vm.isSaveButtonEnabled)
        }
        .padding(.horizontal)
        .padding(.top)
    }

    func buildCreatedDateView() -> some View {
        HStack(alignment: .center) {
            Text(vm.createdDate ?? "")
                .foregroundStyle(.gray)
                .font(.footnote)
        }
    }

    func buildInputView() -> some View {
        Section {
            TextField("장소명", text: $vm.name)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.next)
                .onSubmit { isAddressFocused = true }

            TextField("주소", text: $vm.address)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.next)
                .focused($isAddressFocused)
                .onSubmit { isLongitudeFocused = true }

            TextField("경도", text: $vm.longitude)
                .keyboardType(.numbersAndPunctuation)
                .submitLabel(.next)
                .focused($isLongitudeFocused)
                .onSubmit { isLatitudeFocused = true }

            TextField("위도", text: $vm.latitude)
                .keyboardType(.numbersAndPunctuation)
                .submitLabel(.done)
                .focused($isLatitudeFocused)
                .onSubmit { isLatitudeFocused = false }
        } header: {
            Spacer(minLength: 0)
        }
    }

    func buildOutputView() -> some View {
        Section {
            LabeledContent { Text(vm.name) } label: { Text("장소명") }
            LabeledContent { Text(vm.address) } label: { Text("주소") }
            LabeledContent { Text(vm.longitude) } label: { Text("경도") }
            LabeledContent { Text(vm.latitude) } label: { Text("위도") }
        } header: {
            Spacer(minLength: 0)
        }
    }

    func buildDeleteSpotButton() -> some View {
        Button("장소 삭제하기", role: .destructive) {
            shouldDelete = true
        }
        .alert("정말로 삭제하시겠습니까?", isPresented: $shouldDelete) {
            Button("취소", role: .cancel) { shouldDelete = false }
            Button(role: .destructive) {
                if let spot = vm.spot {
                    vm.deleteSpot(spot)
                    dismiss()
                }
            } label: { Text("삭제") }
        } message: {
            Text("삭제된 장소는 복구되지 않습니다.")
        }
    }

    @ToolbarContentBuilder
    func buildToolbar() -> some ToolbarContent {
        if isEditingMode {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("취소") { isEditingMode = false }
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if isEditingMode {
                Button("저장") {
                    if let spot = vm.spot {
                        vm.updateSpot(spot)
                        dismiss()
                    }
                }
                .disabled(!vm.isSaveButtonEnabled)

            } else {
                Button("편집") { isEditingMode = true }
            }
        }
    }
}

#Preview {
    MySpotView()
}
