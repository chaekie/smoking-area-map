//
//  ModalView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/29/24.
//

import SwiftUI

struct ModalView<T: View>: UIViewControllerRepresentable {
    let view: T
    let isPresented: Bool
    let shouldPreventDismissal: Bool
    let onDismissalAttempt: (() -> Void)?

    func makeUIViewController(context: Context) -> UIHostingController<T> {
        UIHostingController(rootView: view)
    }

    func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {
        context.coordinator.modalView = self
        uiViewController.rootView = view
        uiViewController.parent?.presentationController?.delegate = context.coordinator
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var modalView: ModalView

        init(_ modalView: ModalView) {
            self.modalView = modalView
        }

        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            if modalView.shouldPreventDismissal {
                modalView.onDismissalAttempt?()
                return !modalView.isPresented
            } else {
                return modalView.isPresented
            }
        }
    }
}
