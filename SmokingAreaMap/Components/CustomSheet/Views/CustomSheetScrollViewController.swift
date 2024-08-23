//
//  CustomSheetScrollViewController.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/20/24.
//

import Combine
import SwiftUI

final class CustomSheetScrollViewController: UIViewController {
    var isPresented: Binding<Bool>?
    weak var vm: CustomSheetViewModel?
    private var startPosition = CGFloat.zero

    private var cancellables = Set<AnyCancellable>()
    private let scrollSubject = PassthroughSubject<CGFloat, Never>()
    private let velocitySubject = PassthroughSubject<CGPoint, Never>()

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
    
    private func setupCombineBindings() {
        scrollSubject
            .sink { [weak self] newPosition in
                guard let self, let vm = self.vm else { return }
                vm.isScrollingFromTheTop = startPosition <= 0.0 && newPosition < startPosition
            }
            .store(in: &cancellables)

        velocitySubject
            .sink { [weak self] velocity in
                guard let self else { return }
                self.handleScrollEnd(velocity: velocity)
            }
            .store(in: &cancellables)
    }

    private func handleScrollEnd(velocity: CGPoint) {
        guard let vm else { return }
        let newPosition = scrollView.contentOffset.y

        if vm.isScrollingFromTheTop {
            let isFast = velocity.y < -Constants.BottomSheet.scrollVelocityThreshold
            let isCollapseEnough = newPosition < -Constants.BottomSheet.distanceThreshold

            if isFast || isCollapseEnough {
                vm.showSmallSheet()
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
}

extension CustomSheetScrollViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startPosition = scrollView.contentOffset.y
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newPosition = scrollView.contentOffset.y
        scrollSubject.send(newPosition)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        velocitySubject.send(velocity)
    }
}
