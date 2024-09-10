//
//  CustomSheetScrollViewController.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/20/24.
//

import SwiftUI

final class CustomSheetScrollViewController: UIViewController {
    weak var vm: CustomSheetViewModel?
    private var startOffset = CGFloat.zero

    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.layer.cornerRadius = Constants.BottomSheet.sheetCornerRadius
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupHostingController()
        vm?.onShowLargeSheet = enableBounces
        vm?.onShowSmallSheet = scrollToTop
    }

    private func setupScrollView() {
        scrollView.frame = self.view.bounds
        scrollView.delegate = self
        self.view.addSubview(scrollView)
    }

    private func setupHostingController() {
        guard let vm else { return }
        let hostingController = UIHostingController(rootView: ScrollContentView(vm: vm))
        addChild(hostingController)
        scrollView.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        setupHostingControllerConstraints(hostingController)
        hostingController.sizingOptions = [.intrinsicContentSize]
        hostingController.view.backgroundColor = .clear
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

    private func showFullScreenModal() {
        guard let vm else { return }
        withAnimation(.easeInOut(duration: 0.1)) {
            vm.updateVisibilityIfNeeded(currentValue: &vm.isSheetCoverVisible, newValue: true)
            vm.updateVisibilityIfNeeded(currentValue: &vm.isToolbarVisible, newValue: false)
        }
        self.scrollView.contentInsetAdjustmentBehavior = .always
        self.scrollView.backgroundColor = .white
    }

    private func showCollapsingModal(offset: CGFloat) {
        guard let vm else { return }
        let shouldShowToolbar = offset < -30
        withAnimation(.easeInOut(duration: Constants.BottomSheet.aniDuration)) {
            vm.updateVisibilityIfNeeded(currentValue: &vm.isToolbarVisible, newValue: shouldShowToolbar)
            vm.updateVisibilityIfNeeded(currentValue: &vm.isSheetCoverVisible, newValue: false)
        }
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.scrollView.backgroundColor = .clear
    }

    private func onScrolling(_ newOffset: CGFloat) {
        guard let vm else { return }

        if vm.isSheetCollapsing {
            self.showCollapsingModal(offset: newOffset)
        }

        if newOffset > 0 && vm.currentDetent == .large {
            self.showFullScreenModal()
        }
    }

    private func onDragDidStop(velocity: CGPoint) {
        guard let vm else { return }
        let newOffset = scrollView.contentOffset.y

        if vm.isSheetCollapsing {
            let isFast = velocity.y < -Constants.BottomSheet.scrollVelocityThreshold
            let isCollapseEnough = newOffset < -Constants.BottomSheet.largeToSmallDistanceThreshold
            let shouldCollapseSheet = isFast || isCollapseEnough

            if !shouldCollapseSheet {
                vm.showSheet(detent: .large)
            } else {
                self.scrollView.isScrollEnabled = false
                disableBounces()
                vm.dragOffset = -newOffset + vm.detents.large
                vm.showSheet(detent: .small, duration: 0.15)
            }
        }
    }

    private func onScrollDidStop(_ newPosition: CGFloat) {
        guard let vm else { return }
        if newPosition == 0 && vm.currentDetent == .large {
            self.showFullScreenModal()
        }
    }

    private func enableBounces() {
        scrollView.bounces = true
    }

    private func disableBounces() {
        scrollView.bounces = false
    }

    private func scrollToTop() {
        scrollView.contentOffset.y = 0
    }
}

extension CustomSheetScrollViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startOffset = scrollView.contentOffset.y
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let vm else { return }
        let newOffset = scrollView.contentOffset.y
        vm.updateTitleVisibility(offset: newOffset)
        vm.updateIsSheetCollapsing(offset: newOffset, startOffset: startOffset)
        self.onScrolling(newOffset)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.onDragDidStop(velocity: velocity)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let newOffset = scrollView.contentOffset.y
        self.onScrollDidStop(newOffset)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            let newOffset = scrollView.contentOffset.y
            self.onScrollDidStop(newOffset)
        }
    }
}
