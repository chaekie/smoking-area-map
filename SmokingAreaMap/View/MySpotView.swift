//
//  MySpotView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/16/24.
//

import SwiftUI

struct MySpotView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var mySpotVM: MySpotViewModel

    @State private var isNew = false
    @State private var isEditingMode = false
    @State private var isSearchingModeByTextButton = false
    @State private var isSearchingModeByMapButton = false
    @State private var shouldShowMapThumbnail = false
    @State private var shouldDelete = false

    @Binding var isCreatingNew: Bool?

    init(spot: MySpot? = nil, isCreatingNew: Binding<Bool?> = .constant(nil)) {
        if spot == nil { isNew = true }
        self._mySpotVM = StateObject(wrappedValue: MySpotViewModel(spot))
        self._isCreatingNew = isCreatingNew
    }

    var body: some View {
        ZStack(alignment: .top) {
            if !isNew { buildCreatedDateView() }

            List {
                if !mySpotVM.longitude.isEmpty && !mySpotVM.latitude.isEmpty {
                    buildMapThumbnailView()
                }

                if isNew || isEditingMode {
                    buildInputView()
                } else {
                    buildOutputView()
                }

                if !isNew { buildDeleteSpotButton() }
            }
            .scrollContentBackground(.hidden)
            .animation(.easeInOut, value: isEditingMode)
            .if(isNew) { $0.offset(y: 25) }

            if isNew { buildSheetToolbar() }
        }
        .toolbar { buildToolbar() }
        .environmentObject(mySpotVM)
        .navigationBarBackButtonHidden(isEditingMode)
        .background(Color(UIColor.secondarySystemBackground))
    }

    private func buildCreatedDateView() -> some View {
        HStack {
            Spacer()
            Text(mySpotVM.createdDate ?? "")
                .foregroundStyle(.gray)
                .font(.footnote)
            Spacer()
        }
    }

    private func buildMapThumbnailView() -> some View {
        Button {
            if isEditingMode {
                isSearchingModeByMapButton = true
            }
        } label: {
            SubMapView(
                isPresented: $shouldShowMapThumbnail,
                mapMode: MapMode.showing)
            .frame(height: 250)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .fullScreenCover(isPresented: $isSearchingModeByMapButton) {
            SubMapView(isPresented: $isSearchingModeByMapButton, mapMode: MapMode.searching)
        }
        .disabled(!isEditingMode)
        .listRowInsets(EdgeInsets())
    }

    private func buildOutputView() -> some View {
        Section {
            LabeledContent { Text(mySpotVM.name) } label: { Text("장소명") }
            LabeledContent { Text(mySpotVM.address) } label: { Text("위치") }
        }
    }

    private func buildInputView() -> some View {
        Section {
            RoundedBorderView(label: "장소명") {
                TextField("명칭을 입력해주세요", text: $mySpotVM.name)
            }

            RoundedBorderView(label: "위치") {
                buildSearchAddressButton()
            }
        }
    }

    private func buildSearchAddressButton() -> some View {
        let hasAddress = !mySpotVM.address.isEmpty

        return Button {
            isSearchingModeByTextButton = true
        } label: {
            HStack {
                Text(hasAddress ? mySpotVM.address : "여기를 눌러 주소를 검색하세요.")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(hasAddress ? .gray : .blue)
            }
        }.fullScreenCover(isPresented: $isSearchingModeByTextButton) {
            SubMapView(isPresented: $isSearchingModeByTextButton, mapMode: MapMode.searching)
        }
    }

    private func buildDeleteSpotButton() -> some View {
        Button("장소 삭제하기", role: .destructive) {
            shouldDelete = true
        }
        .alert("정말로 삭제하시겠습니까?", isPresented: $shouldDelete) {
            Button("취소", role: .cancel) { shouldDelete = false }
            Button(role: .destructive) {
                if let spot = mySpotVM.spot {
                    mySpotVM.deleteSpot(spot)
                    dismiss()
                }
            } label: { Text("삭제") }
        } message: {
            Text("삭제된 장소는 복구되지 않습니다.")
        }
    }

    private func buildSheetToolbar() -> some View {
        HStack {
            Button("취소") {
                dismiss()
            }
            Spacer()
            Button("저장") {
                mySpotVM.createSpot()
                isCreatingNew = true
                dismiss()
            }
            .disabled(!mySpotVM.isSaveButtonEnabled)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }

    @ToolbarContentBuilder
    private func buildToolbar() -> some ToolbarContent {
        if isEditingMode {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("취소") { isEditingMode = false }
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if isEditingMode {
                Button("저장") {
                    if let spot = mySpotVM.spot {
                        mySpotVM.updateSpot(spot)
                        isEditingMode = false
                    }
                }
                .disabled(!mySpotVM.isSaveButtonEnabled)

            } else {
                Button("편집") { isEditingMode = true }
            }
        }
    }
}

#Preview {
    MySpotView()
}
