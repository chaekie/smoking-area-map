//
//  CustomSheetViewModel.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/22/24.
//

import Combine
import SwiftUI

final class CustomSheetViewModel: ObservableObject {
    @Published var screenHeight = CGFloat.zero
    @Published var lastOffset = Constants.BottomSheet.initPosition
    @Published var dragOffset = Constants.BottomSheet.initPosition
    @Published var swipeDirection = SwipeDirection.up
    @Published var isScrollEnabled = false
    @Published var isScrollingFromTheTop = false
    @Published var detents = DetentPositions(closed: Constants.BottomSheet.initPosition,
                                     small: Constants.BottomSheet.initPosition,
                                     large: 0)

    private var cancellables = Set<AnyCancellable>()
    private let dragSubject = PassthroughSubject<DragGesture.Value, Never>()

    init() {
        setupGestureHandling()
    }

    private func setupGestureHandling() {
        dragSubject
            .sink { [weak self] gesture in
                guard let self else { return }
                self.handleDragChange(gesture: gesture)
            }
            .store(in: &cancellables)

        dragSubject
            .map { $0.velocity.height }
            .sink { [weak self] velocity in
                self?.handleSwipe(velocity: velocity)
            }
            .store(in: &cancellables)
    }

    private func handleDragChange(gesture: DragGesture.Value) {
        if !isScrollEnabled {
            dragOffset = lastOffset + gesture.translation.height
        }
        setSwipeDirection(by: gesture.velocity.height)
        constrainSheetHeight()
    }

    private func setSwipeDirection(by velocity: CGFloat) {
        if velocity < 0 {
            swipeDirection = .up
        } else {
            swipeDirection = .down
        }
    }

    private func constrainSheetHeight() {
        if dragOffset > detents.small {
            dragOffset = detents.small
        } else if dragOffset < detents.large {
            dragOffset = detents.large
        }
    }

    private func handleSwipe(velocity: CGFloat) {
        let isFastSwipeUp = velocity < -Constants.BottomSheet.dragVelocityThreshold
        let isFastSwipeDown = velocity > Constants.BottomSheet.dragVelocityThreshold

        if isFastSwipeDown {
            showSmallSheet()
        } else if isFastSwipeUp {
            showLargeSheet()
        } else {
            handleSlowSwipe(dragOffset: dragOffset)
        }

        lastOffset = dragOffset
    }

    func showSmallSheet() {
        withAnimation(.spring(duration: Constants.BottomSheet.aniDuration)) {
            lastOffset = detents.small
            dragOffset = detents.small
            isScrollEnabled = false
        }
    }

    func showLargeSheet() {
        withAnimation(.spring(duration: Constants.BottomSheet.aniDuration)) {
            lastOffset = detents.large
            dragOffset = detents.large
            isScrollEnabled = true
        }
    }

    func hideSheet() {
        withAnimation(.spring(duration: Constants.BottomSheet.aniDuration)) {
            lastOffset = detents.closed
            dragOffset = detents.closed
        }
    }

    private func handleSlowSwipe(dragOffset: CGFloat) {
        let shouldExpandSheet = dragOffset < detents.small
        let shouldCollapseSheet = dragOffset > Constants.BottomSheet.distanceThreshold

        switch swipeDirection {
        case .up:
            if shouldExpandSheet {
                showLargeSheet()
            } else {
                showSmallSheet()
            }
        case .down:
            if shouldCollapseSheet {
                showLargeSheet()
            } else {
                showSmallSheet()
            }
        }
    }

    func setDetents() {
        detents.closed = screenHeight
        detents.small = screenHeight * Constants.BottomSheet.smallSheetHeightRatio
    }

    func onDragGestureChanged(_ gesture: DragGesture.Value) {
        dragSubject.send(gesture)
    }
}
