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
    @EnvironmentObject var mySpotVM: MySpotViewModel
    @Binding var isPresented: Bool
    @Binding var shouldAlert: Bool

    @FocusState private var isFocused: Bool
    private var spot: MySpot?

    @State private var shouldSearchMap = false
    @State private var shouldDelete = false

    @State private var shouldShowPhotosPicker = false
    @State private var shouldShowCamera = false

    init(spot: MySpot? = nil,
         isPresented: Binding<Bool> = .constant(false),
         shouldAlert: Binding<Bool>) {
        self.spot = spot
        self._isPresented = isPresented
        self._shouldAlert = shouldAlert
    }

    var body: some View {
        ZStack(alignment: .top) {
            if let spot = mySpotVM.spot { buildCreatedDateView(spot) }

            List {
                switch mySpotVM.contentMode {
                case .creating:
                    buildInputView()
                case .reading:
                    if let spot {
                        buildOutputView(spot)
                        buildDeleteSpotButton(spot)
                    }
                case .updating:
                    if let spot {
                        buildInputView()
                        buildDeleteSpotButton(spot)
                    }
                default: EmptyView()
                }
            }
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .if(mySpotVM.contentMode == .creating) { $0.offset(y: 25) }
            .padding(.bottom, 30)
            .simultaneousGesture(TapGesture().onEnded { _ in
                if isFocused { isFocused = false }
            })

            if mySpotVM.contentMode == .creating { buildSheetToolbar() }
        }
        .onAppear() {
            mySpotVM.setUpSpot(spot)
        }
        .onDisappear() {
            mySpotVM.resetSpot()
        }
        .toolbar {
            switch mySpotVM.contentMode {
            case .updating:
                buildCancelToolbarItem()
                buildUpdateToolbarItem()
            default:
                buildEditToolbarItem()
            }
        }
        .fullScreenCover(isPresented: $shouldSearchMap) {
            SubMapView(mapMode: MapMode.searching)
        }
        .confirmationDialog("저장하지 않고 나가기", isPresented: $shouldAlert) {
            Button("입력 사항 폐기", role: .destructive) {
                switch mySpotVM.contentMode {
                case .creating:
                    isPresented = false
                case .updating:
                    mySpotVM.contentMode = .reading
                default: break
                }
            }
            Button("계속 입력하기", role: .cancel) { }
        } message: {
            Text("입력한 내용을 폐기하시겠습니까?")
        }
        .animation(.easeInOut, value: mySpotVM.contentMode)
        .navigationBarBackButtonHidden(mySpotVM.contentMode == .updating)
        .background(Color(UIColor.secondarySystemBackground))
    }

    private func buildCreatedDateView(_ spot: MySpot) -> some View {
        HStack {
            Spacer()
            Text(spot.dateString)
                .foregroundStyle(.gray)
                .font(.footnote)
            Spacer()
        }
    }

    private func buildOutputView(_ spot: MySpot) -> some View {
        Group {
            Section {
                LabeledContent { Text(spot.name) } label: { Text("장소명") }
                LabeledContent { Text(spot.address) } label: { Text("위치") }
                if !spot.longitude.isNaN && !spot.latitude.isNaN {
                    buildMapThumbnailView()
                }
            }

            if let photo = spot.photo {
                Section {
                    Text("사진").bold()
                    buildPhotoThumbnailView(photo)
                        .listRowInsets(EdgeInsets())
                }
            }
        }
    }

    private func buildInputView() -> some View {
        Group {
            Section {
                RoundedBorderView(label: "장소명", isRequired: true) {
                    TextField("명칭을 입력해주세요", text: $mySpotVM.tempName)
                        .focused($isFocused)
                }

                RoundedBorderView(label: "위치", isRequired: true) {
                    buildSearchAddressButton()
                }

                if !mySpotVM.tempLongitude.isEmpty && !mySpotVM.tempLatitude.isEmpty {
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
        .listRowInsets(EdgeInsets())
        .onTapGesture {
            if mySpotVM.contentMode != .reading {
                shouldSearchMap = true
            }
        }
    }

    @ViewBuilder
    private func buildPhotoListRowView() -> some View {
        if let photo = mySpotVM.tempPhoto {
            Group {
                Text("사진").bold()
                buildPhotoThumbnailView(photo)
                    .listRowInsets(EdgeInsets())
            }
        } else {
            RoundedBorderView(label: "사진") {
                buildAddPhotoMenu()
            }
        }
    }

    private func buildAddPhotoMenu() -> some View {
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
                      selection: $mySpotVM.selectedPhoto,
                      matching: .images)
        .task(id: mySpotVM.selectedPhoto) {
            if let selectedPhoto = mySpotVM.selectedPhoto {
                await mySpotVM.setPhoto(from: selectedPhoto)
            }
        }
        .fullScreenCover(isPresented: $shouldShowCamera) {
            AccessCameraView(selectedPhoto: $mySpotVM.tempPhoto)
                .ignoresSafeArea()
        }
    }

    private func buildMenuLabel() -> some View {
        HStack {
            if mySpotVM.tempPhoto == nil { Spacer() }
            Image(systemName: "camera.fill")
            Text("사진 \(mySpotVM.tempPhoto == nil ? "추가" : "변경")")
            if mySpotVM.tempPhoto == nil { Spacer() }
        }
        .if(mySpotVM.tempPhoto != nil) {
            $0.padding(.vertical, 10)
                .padding(.horizontal, 13)
                .foregroundStyle(.white)
                .background(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom)
        }
    }

    @ViewBuilder
    private func buildPhotoThumbnailView(_ photo: Data) -> some View {
        if let uiImage = UIImage(data: photo) {
            Image(uiImage: uiImage)
                .resizable()
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 250)
                .if(mySpotVM.contentMode != .reading) {
                    $0.overlay(alignment: .bottom) {
                        buildAddPhotoMenu()
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
                mySpotVM.deletePhoto()
            }
        }
    }

    private func buildSearchAddressButton() -> some View {
        let hasAddress = !mySpotVM.tempAddress.isEmpty

        return Button {} label: {
            HStack {
                Text(hasAddress ? mySpotVM.tempAddress : "여기를 눌러 주소를 검색하세요.")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(hasAddress ? .gray : .blue)
            }
        }
        .onTapGesture {
            shouldSearchMap = true
        }
    }

    private func buildDeleteSpotButton(_ spot: MySpot) -> some View {
        Button("장소 삭제하기", role: .destructive) {
            shouldDelete = true
        }
        .alert("정말로 삭제하시겠습니까?", isPresented: $shouldDelete) {
            Button("취소", role: .cancel) { shouldDelete = false }
            Button(role: .destructive) {
                mySpotVM.deleteSpot(spot)
                dismiss()
            } label: { Text("삭제") }
        } message: {
            Text("삭제된 장소는 복구되지 않습니다.")
        }
    }

    private func buildSheetToolbar() -> some View {
        HStack {
            Button("취소") {
                if mySpotVM.isEditing {
                    shouldAlert = true
                } else {
                    dismiss()
                }
            }
            Spacer()
            Button("저장") {
                mySpotVM.createSpot()
                dismiss()
            }
            .disabled(!mySpotVM.isSaveButtonEnabled)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }

    private func buildCancelToolbarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("취소") {
                if mySpotVM.isEditing {
                    shouldAlert = true
                } else {
                    mySpotVM.contentMode = .reading
                }
            }
        }
    }

    private func buildUpdateToolbarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("저장") {
                if let spot = mySpotVM.spot {
                    mySpotVM.updateSpot(spot)
                    mySpotVM.contentMode = .reading
                }
            }
            .disabled(!mySpotVM.isSaveButtonEnabled)
        }
    }

    private func buildEditToolbarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("편집") {
                mySpotVM.contentMode = .updating
            }
        }
    }
}
