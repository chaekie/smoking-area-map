//
//  ScrollViewControllerRepresentable.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/20/24.
//

import UIKit
import SwiftUI

struct ScrollViewControllerRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject var vm: CustomSheetViewModel
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> ScrollViewController {
        let scrollVC = ScrollViewController()
        scrollVC.isPresented = $isPresented
        scrollVC.vm = vm
        return scrollVC
    }

    func updateUIViewController(_ uiViewController: ScrollViewController, context: Context) {
        uiViewController.scrollView.isScrollEnabled = vm.isScrollEnabled
    }
}

final class ScrollViewController: UIViewController, UIScrollViewDelegate {
    var isPresented: Binding<Bool>?
    var vm: CustomSheetViewModel?
    private var startPosition = CGFloat.zero

    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 5
        view.layer.masksToBounds = false
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupHostingController()
    }

    private func setupScrollView() {
        scrollView.frame = self.view.bounds
        scrollView.delegate = self
        self.view.addSubview(scrollView)
    }

    private func setupHostingController() {
        guard let isPresented else { return }
        let hostingController = UIHostingController(rootView: ScrollContentView(isPresented: isPresented,
                                                                                collapseSheet: collapseSheet))
        addChild(hostingController)
        scrollView.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        setupHostingControllerConstraints(hostingController)
        scrollView.contentSize = hostingController.view.intrinsicContentSize
    }

    private func setupHostingControllerConstraints(_ hostingController: UIHostingController<ScrollContentView>) {
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startPosition = scrollView.contentOffset.y
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newPosition = scrollView.contentOffset.y
        vm?.isScrollingFromTheTop = isScrollDownStartFromTheTop(newPosition)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, 
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let vm else { return }
        let newPosition = scrollView.contentOffset.y

        if isScrollDownStartFromTheTop(newPosition) {
            let isFast = velocity.y < -1
            let isCollapseEnough = newPosition < -100

            if isFast || isCollapseEnough {
                vm.showSmallSheet()
            } else {
                vm.showLargeSheet()
                scrollView.contentOffset.y = 0
            }
        }
    }

    private func isScrollDownStartFromTheTop(_ newPosition: CGFloat) -> Bool {
        return startPosition <= 0.0 && newPosition < startPosition
    }

    func collapseSheet() {
        guard let vm else { return }
        vm.showSmallSheet()
        scrollView.contentOffset.y = 0
    }
}
