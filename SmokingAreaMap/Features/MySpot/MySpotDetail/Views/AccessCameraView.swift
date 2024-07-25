//
//  AccessCameraView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/25/24.
//

import SwiftUI

struct AccessCameraView: UIViewControllerRepresentable {

    @Binding var selectedPhoto: Data?
    @Environment(\.presentationMode) var isPresented

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }

    func makeCoordinator() -> CameraCoordinator {
        return CameraCoordinator(picker: self)
    }
    
    class CameraCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var picker: AccessCameraView

        init(picker: AccessCameraView) {
            self.picker = picker
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let selectedImage = info[.originalImage] as? UIImage else { return }
            self.picker.selectedPhoto = selectedImage.jpegData(compressionQuality: 1)
            self.picker.isPresented.wrappedValue.dismiss()
        }
    }
}
