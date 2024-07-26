//
//  MySpotDetailView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/16/24.
//

import PhotosUI
import SwiftUI

struct MySpotDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var mySpotVM: MySpotDetailViewModel

    @Binding var isCreatingNew: Bool?
    @FocusState private var isFocused: Bool

    @State private var isNew = false
    @State private var isEditingMode = false
    @State private var isSearchingMode = false
    @State private var shouldDelete = false

    @State private var shouldShowPhotosPicker = false
    @State private var shouldShowCamera = false
    @State private var selectedPhoto: PhotosPickerItem?

    init(spot: MySpot? = nil,
         isCreatingNew: Binding<Bool?> = .constant(nil)) {
        if spot == nil { isNew = true }
        self._mySpotVM = StateObject(wrappedValue: MySpotDetailViewModel(spot))
        self._isCreatingNew = isCreatingNew
    }

    var body: some View {
        ZStack(alignment: .top) {
            if !isNew { buildCreatedDateView() }

            List {
                if isNew || isEditingMode {
                    buildInputView()
                } else {
                    buildOutputView()
                }

                if !isNew { buildDeleteSpotButton() }
            }
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .animation(.easeInOut, value: isEditingMode)
            .if(isNew) { $0.offset(y: 25) }
            .padding(.bottom, 30)
            .simultaneousGesture(TapGesture().onEnded { _ in
                if isFocused { isFocused = false }
            })
            .fullScreenCover(isPresented: $isSearchingMode) {
                SubMapView(mapMode: MapMode.searching)
            }

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

    private func buildOutputView() -> some View {
        Group {
            Section {
                LabeledContent { Text(mySpotVM.name) } label: { Text("장소명") }
                LabeledContent { Text(mySpotVM.address) } label: { Text("위치") }
                if !mySpotVM.longitude.isEmpty && !mySpotVM.latitude.isEmpty {
                    buildMapThumbnailView()
                }
            }

            if mySpotVM.photo != nil {
                Section {
                    Text("사진").bold()
                    buildPhotoThumbnailView()
                        .listRowInsets(EdgeInsets())
                }
            }
        }
    }

    private func buildInputView() -> some View {
        Group {
            Section {
                RoundedBorderView(label: "장소명", isRequired: true) {
                    TextField("명칭을 입력해주세요", text: $mySpotVM.name)
                        .focused($isFocused)
                }

                RoundedBorderView(label: "위치", isRequired: true) {
                    buildSearchAddressButton()
                }

                if !mySpotVM.longitude.isEmpty && !mySpotVM.latitude.isEmpty {
                    buildMapThumbnailView()
                }
            }

            Section {
                buildPhotoListRowView()
            }
        }
    }

    private func buildMapThumbnailView() -> some View {
        Button {} label: {
            SubMapView(mapMode: MapMode.showing)
                .frame(height: MapMode.showing.height)
        }
        .disabled(!isNew && !isEditingMode)
        .listRowInsets(EdgeInsets())
        .onTapGesture {
            isSearchingMode.toggle()
        }
    }

    @ViewBuilder
    private func buildPhotoListRowView() -> some View {
        if mySpotVM.photo == nil {
            RoundedBorderView(label: "사진") {
                buildAddPhotoButton()
            }
        } else {
            Group {
                Text("사진").bold()
                buildPhotoThumbnailView()
                    .listRowInsets(EdgeInsets())
            }
        }
    }

    private func buildAddPhotoButton() -> some View {
        Menu {
            Button {
                shouldShowPhotosPicker.toggle()
            } label: {
                Label("사진 보관함", systemImage: "photo")
            }

            Button {
                shouldShowCamera.toggle()
            } label: {
                Label("사진 찍기", systemImage: "camera")
            }
        } label: {
            buildMenuLabel()
        }
        .photosPicker(isPresented: $shouldShowPhotosPicker,
                      selection: $selectedPhoto,
                      matching: .images)
        .task(id: selectedPhoto) {
            if let selectedPhoto {
                await mySpotVM.setPhoto(from: selectedPhoto)
            }
        }
        .fullScreenCover(isPresented: $shouldShowCamera) {
            AccessCameraView(selectedPhoto: $mySpotVM.photo)
                .ignoresSafeArea()
        }
    }

    private func buildMenuLabel() -> some View {
        HStack {
            if mySpotVM.photo == nil { Spacer() }
            Image(systemName: "camera.fill")
            Text("사진 \(mySpotVM.photo == nil ? "추가" : "변경")")
            if mySpotVM.photo == nil { Spacer() }
        }
        .if(mySpotVM.photo != nil) {
            $0.padding(.vertical, 10)
                .padding(.horizontal, 13)
                .foregroundStyle(.white)
                .background(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom)
        }
    }

    @ViewBuilder
    private func buildPhotoThumbnailView() -> some View {
        if let photo = mySpotVM.photo,
           let uiImage = UIImage(data: photo) {
            Image(uiImage: uiImage)
                .resizable()
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 250)
                .if(isEditingMode || isNew) {
                    $0.overlay(alignment: .bottom) {
                        buildAddPhotoButton()
                    }
                    .overlay(alignment: .topTrailing) {
                        buildDeletePhotoButton()
                    }
                }
        }
    }

    private func buildDeletePhotoButton() -> some View {
        HStack {
            Spacer()
            Button {} label: {
                Image(systemName: "trash")
                    .bold()
                    .padding(10)
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .padding(.trailing, 10)
                    .padding(.top, 10)
            }
            .onTapGesture {
                selectedPhoto = nil
                mySpotVM.photo = nil
            }
        }
    }

    private func buildSearchAddressButton() -> some View {
        let hasAddress = !mySpotVM.address.isEmpty

        return Button {} label: {
            HStack {
                Text(hasAddress ? mySpotVM.address : "여기를 눌러 주소를 검색하세요.")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(hasAddress ? .gray : .blue)
            }
        }
        .onTapGesture {
            isSearchingMode.toggle()
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
    MySpotDetailView()
}
