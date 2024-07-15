//
//  BottomSheetView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/28/24.
//

import SwiftUI

struct BottomSheetView<Content: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIHostingController<Content>

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

    func makeUIViewController(context: Context) -> UIHostingController<Content> {
        UIViewControllerType(rootView: content)
    }

    func updateUIViewController(_ hostingController: UIViewControllerType, context: Context) {
        if isPresented == false {
            context.coordinator.isStillPresenting = false

        } else {
            hostingController.rootView = content

            if context.coordinator.isStillPresenting == false {
                setUp(hostingController, context: context)
                context.coordinator.isStillPresenting = true
            }
        }
    }

    func setUp(_ hostingController: UIViewControllerType, context: Context) {
        let vc = UIViewController()
        vc.addChild(hostingController)
        vc.view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: vc.view.topAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
        ])
        hostingController.didMove(toParent: vc)

        if let sheetController = vc.presentationController as? UISheetPresentationController {
            sheetController.detents = detents
            sheetController.prefersGrabberVisible = true
            sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
            sheetController.largestUndimmedDetentIdentifier = detents[0].identifier
        }

        vc.presentationController?.delegate = context.coordinator
        guard let rootVC = UIApplication.shared.firstKeyWindow?.rootViewController else { return }
        rootVC.present(vc, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        var parent: BottomSheetView
        var isStillPresenting = false

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

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
}
