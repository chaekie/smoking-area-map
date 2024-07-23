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
        VStack(spacing: 0) {
            if isNew { buildSheetToolbar() }
            if !isNew { buildCreatedDateView() }
            if !mySpotVM.longitude.isEmpty && !mySpotVM.latitude.isEmpty {
                buildMapThumbnailView()
            }
            List {
                if isNew || isEditingMode {
                    buildInputView()
                } else {
                    buildOutputView()
                }
                if !isNew { buildDeleteSpotButton() }
            }
        }
        .environmentObject(mySpotVM)
        .toolbar {
            buildToolbar()
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationBarBackButtonHidden(isEditingMode)
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
        .padding(.horizontal)
        .padding(.top)
    }

    private func buildCreatedDateView() -> some View {
        HStack(alignment: .center) {
            Text(mySpotVM.createdDate ?? "")
                .foregroundStyle(.gray)
                .font(.footnote)
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
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $isSearchingModeByMapButton) {
            SubMapView(isPresented: $isSearchingModeByMapButton, mapMode: MapMode.searching)
        }
        .disabled(!isEditingMode)
    }

    private func buildInputView() -> some View {
        Group {
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

    private func buildOutputView() -> some View {
        Group {
            LabeledContent { Text(mySpotVM.name) } label: { Text("장소명") }
            LabeledContent { Text(mySpotVM.address) } label: { Text("주소") }
            LabeledContent { Text(mySpotVM.longitude) } label: { Text("경도") }
            LabeledContent { Text(mySpotVM.latitude) } label: { Text("위도") }
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
                        dismiss()
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
