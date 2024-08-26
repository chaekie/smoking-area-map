//
//  CustomSheetScrollViewController.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/20/24.
//

import SwiftUI

final class CustomSheetScrollViewController: UIViewController {
    weak var vm: CustomSheetViewModel?
    private var startPosition = CGFloat.zero

    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupHostingController()
        vm?.onShowLargeSheet = enableBounces
    }

    private func setupScrollView() {
        scrollView.frame = self.view.bounds
        scrollView.delegate = self
        self.view.addSubview(scrollView)
    }

    private func setupHostingController() {
        let hostingController = UIHostingController(rootView: ScrollContentView(collapseSheet: collapseSheet))
        addChild(hostingController)
        scrollView.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        setupHostingControllerConstraints(hostingController)
        hostingController.sizingOptions = [.intrinsicContentSize]
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

    private func updateScrollingFromTopOnScroll(_ newPosition: CGFloat) {
        guard let vm else { return }
        if !vm.isScrollingFromTheTop {
            vm.isScrollingFromTheTop = startPosition <= 0.0 && newPosition < startPosition
        }
    }

    private func updateScrollingFromTopOnEnd(_ newPosition: CGFloat) {
        guard let vm else { return }
        if vm.isScrollingFromTheTop {
            vm.isScrollingFromTheTop = startPosition <= 0.0 && newPosition < startPosition
        }
    }

    private func handleScrollEnd(velocity: CGPoint) {
        guard let vm else { return }
        let newPosition = scrollView.contentOffset.y

        if vm.isScrollingFromTheTop {
            let isFast = velocity.y < -Constants.BottomSheet.scrollVelocityThreshold
            let isCollapseEnough = newPosition < -Constants.BottomSheet.distanceThreshold

            if isFast || isCollapseEnough {
                vm.dragOffset = -newPosition
                vm.showSmallSheet(duration: 0.1)
                disableBounces()
            } else {
                vm.showLargeSheet()
                scrollView.contentOffset.y = 0
            }
        }
    }

    func collapseSheet() {
        guard let vm else { return }
        vm.showSmallSheet()
        scrollView.contentOffset.y = 0
    }

    private func enableBounces() {
        scrollView.bounces = true
    }

    private func disableBounces() {
        scrollView.bounces = false
    }
}

extension CustomSheetScrollViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startPosition = scrollView.contentOffset.y
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newPosition = scrollView.contentOffset.y
        self.updateScrollingFromTopOnScroll(newPosition)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let newPosition = scrollView.contentOffset.y
        self.updateScrollingFromTopOnEnd(newPosition)
        self.handleScrollEnd(velocity: velocity)
    }
}
