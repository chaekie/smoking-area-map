//
//  CustomSheetViewModel.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/22/24.
//

import SwiftUI

final class CustomSheetViewModel: ObservableObject {
    @Published var screenHeight = CGFloat.zero
    @Published var lastOffset = Constants.BottomSheet.initPosition
    @Published var dragOffset = Constants.BottomSheet.initPosition
    @Published var swipeDirection = SwipeDirection.up
    @Published var isScrollEnabled = false
    @Published var isScrollingFromTheTop = false
    @Published var detents = Detents(closed: Constants.BottomSheet.initPosition,
                                         small: Constants.BottomSheet.initPosition,
                                         large: 0)

    func setDetents() {
        detents.closed = screenHeight
        detents.small = screenHeight * 4/5
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

    func setSwipeDirection(by velocity: CGFloat) {
        if velocity < 0 {
            swipeDirection = .up
        } else {
            swipeDirection = .down
        }
    }

    func constrainSheetHeight() {
        if dragOffset > detents.small {
            dragOffset = detents.small
        } else if dragOffset < detents.large {
            dragOffset = detents.large
        }
    }

    func handleSwipe(velocity: CGFloat) {
        let isFastSwipeUp = velocity < -Constants.BottomSheet.standardVelocity
        let isFastSwipeDown = velocity > Constants.BottomSheet.standardVelocity

        if isFastSwipeDown {
            showSmallSheet()
        } else if isFastSwipeUp {
            showLargeSheet()
        } else {
            handleSlowSwipe(dragOffset: dragOffset)
        }

        lastOffset = dragOffset
    }

    func handleSlowSwipe(dragOffset: CGFloat) {
        let shouldExpandSheet = dragOffset < detents.small
        let shouldCollapseSheet = dragOffset > 100

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
}
