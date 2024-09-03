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
    }

    private func setupScrollView() {
        scrollView.frame = self.view.bounds
        scrollView.delegate = self
        self.view.addSubview(scrollView)
    }

    private func setupHostingController() {
        guard let vm else { return }
        let hostingController = UIHostingController(rootView: ScrollContentView(vm: vm, collapseSheet: collapseSheet))
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    private func updateIsScrollingDownFromTopIfNeeded(newValue: Bool) {
        guard let vm else { return }
        if vm.isScrollingDownFromTop == false && newValue == true {
            vm.isScrollingDownFromTop = true
        }
    }

    private func updateScrollingFromTopOnScrollStart(_ newPosition: CGFloat) {
        guard let vm else { return }
        let isScrollingDownFromTop = startPosition <= 0 && (newPosition <= startPosition)
        updateIsScrollingDownFromTopIfNeeded(newValue: isScrollingDownFromTop)
        if isScrollingDownFromTop {
            self.scrollView.backgroundColor = .clear
            vm.updateIsSheetHeaderVisibleIfNeeded(condition: false)
            vm.updateIsToolbarVisibleIfNeeded(condition: true)
        } else {
            if newPosition > 0 {
                self.scrollView.backgroundColor = .white
                vm.updateIsSheetHeaderVisibleIfNeeded(condition: true)
                vm.updateIsToolbarVisibleIfNeeded(condition: false)
            }
        }
    }

    private func updateScrollingFromTopOnScrollEnd(_ newPosition: CGFloat) {
    }

    private func handleScrollEnd(velocity: CGPoint) {
        guard let vm else { return }
        let newPosition = scrollView.contentOffset.y

        if vm.isScrollingDownFromTop {
            let isFast = velocity.y < -Constants.BottomSheet.scrollVelocityThreshold
            let isCollapseEnough = newPosition < -Constants.BottomSheet.distanceThreshold

            if isFast || isCollapseEnough {
                vm.dragOffset = -newPosition + vm.detents.large
                vm.showSmallSheet(duration: 0.15)
                disableBounces()
            } else {
                vm.showLargeSheet()
            }
            scrollView.contentOffset.y = 0
            scrollView.backgroundColor = .white
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
        self.updateScrollingFromTopOnScrollStart(newPosition)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let newPosition = scrollView.contentOffset.y
        self.updateScrollingFromTopOnScrollEnd(newPosition)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            let newPosition = scrollView.contentOffset.y
            self.updateScrollingFromTopOnScrollEnd(newPosition)
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.handleScrollEnd(velocity: velocity)
    }
}
