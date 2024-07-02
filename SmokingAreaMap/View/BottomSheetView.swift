//
//  BottomSheetView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/28/24.
//

import SwiftUI

struct BottomSheetView<Content: View>: UIViewRepresentable {
    @Binding var isPresented: Bool
    let detents: [UISheetPresentationController.Detent]
    let content: Content

    init(
        _ isPresented: Binding<Bool>,
        detents: [UISheetPresentationController.Detent] = [.medium()],
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.detents = detents
        self.content = content()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let rootVC = uiView.window?.rootViewController else { return }

        if rootVC.presentedViewController == nil && isPresented {
            setUp(on: rootVC, context: context)
        }
    }

    func setUp(on rootVC: UIViewController, context: Context) {
        let vc = UIViewController()
        let hc = UIHostingController(rootView: content)

        vc.addChild(hc)
        vc.view.addSubview(hc.view)

        hc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hc.view.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            hc.view.topAnchor.constraint(equalTo: vc.view.topAnchor),
            hc.view.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            hc.view.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
        ])
        hc.didMove(toParent: vc)

        if let sheetController = vc.presentationController as? UISheetPresentationController {
            sheetController.detents = detents
            sheetController.prefersGrabberVisible = true
            sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
            sheetController.largestUndimmedDetentIdentifier = detents[0].identifier
        }

        vc.presentationController?.delegate = context.coordinator

        rootVC.present(vc, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        var parent: BottomSheetView

        init(parent: BottomSheetView) {
            self.parent = parent
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.isPresented = false
        }
    }
}

struct BottomSheetViewModifier<SwiftUIContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let detents: [UISheetPresentationController.Detent]
    let swiftUIContent: SwiftUIContent

    init(
        isPresented: Binding<Bool>,
        detents: [UISheetPresentationController.Detent],
        content: () -> SwiftUIContent
    ) {
        self._isPresented = isPresented
        self.detents = detents
        self.swiftUIContent = content()
    }

    func body(content: Content) -> some View {
        ZStack {
            BottomSheetView($isPresented, detents: detents) {
                swiftUIContent
            }.fixedSize()
            content
        }
    }
}


extension View {

    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: [UISheetPresentationController.Detent],
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(BottomSheetViewModifier(
            isPresented: isPresented,
            detents: detents,
            content: content)
        )
    }

}

extension UISheetPresentationController.Detent.Identifier {
    static let customHeight = UISheetPresentationController.Detent.Identifier("customHeight")
}
