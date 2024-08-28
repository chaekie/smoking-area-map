//
//  CustomSheetViewModel.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/22/24.
//

import SwiftUI

final class CustomSheetViewModel: ObservableObject {
    @Published var spot: SpotPoi?
    @Published var dragOffset = Constants.BottomSheet.initPosition
    @Published var lastOffset = Constants.BottomSheet.initPosition
    @Published var isScrollEnabled = false
    @Published var isScrollingFromTheTop = false
    @Published var currentDetent = Detent.closed
    @Published var detents = DetentPositions(closed: Constants.BottomSheet.initPosition,
                                             small: Constants.BottomSheet.initPosition,
                                             large: 0)
    var onShowLargeSheet: (() -> Void)?

    func handleDragChange(gesture: DragGesture.Value) {
        if !isScrollEnabled {
            let isDragStartAboveSafeArea = gesture.startLocation.y < UIScreen.screenSize.height - UIScreen.safeAreaInsets.bottom
            if isDragStartAboveSafeArea {
                withAnimation(.spring(response: Constants.BottomSheet.aniDuration,
                                      dampingFraction: 0.6,
                                      blendDuration: 0)) {
                    dragOffset = lastOffset + gesture.translation.height
                }
            }
        }
        constrainSheetHeight()
    }

    private func constrainSheetHeight() {
        if dragOffset > detents.small {
            dragOffset = detents.small
        } else if dragOffset < detents.large {
            dragOffset = detents.large
        }
    }

    func handleSheetDetent(gesture: DragGesture.Value) {
        let velocity = gesture.velocity.height
        let distance = gesture.translation.height
        let isFastSwipeUp = velocity < -Constants.BottomSheet.dragVelocityThreshold
        let isFastSwipeDown = velocity > Constants.BottomSheet.dragVelocityThreshold

        if isFastSwipeDown {
            showSmallSheet()
        } else if isFastSwipeUp {
            showLargeSheet()
        } else {
            handleSlowSwipe(distance: distance)
        }

        lastOffset = dragOffset
    }

    func showSmallSheet(duration: CGFloat = Constants.BottomSheet.aniDuration) {
        withAnimation(.linear(duration: duration)) {
            lastOffset = detents.small
            dragOffset = detents.small
            currentDetent = .small
            isScrollEnabled = false
        }
    }

    func showLargeSheet() {
        withAnimation(.linear(duration: Constants.BottomSheet.aniDuration)) {
            dragOffset = detents.large
            lastOffset = detents.large
            currentDetent = .large
            isScrollEnabled = true
        }
        onShowLargeSheet?()
    }

    func hideSheet() {
        lastOffset = detents.closed
        dragOffset = detents.closed
        currentDetent = .closed
    }

    private func handleSlowSwipe(distance: CGFloat) {
        let isInThresholdRange = abs(distance) < Constants.BottomSheet.distanceThreshold
        
        switch currentDetent {
        case .small:
            isInThresholdRange ? showSmallSheet() : showLargeSheet()
        case .large:
            isInThresholdRange ? showLargeSheet() : showSmallSheet()
        default: break
        }
    }

    func setDetents() {
        let screenHeight = UIScreen.screenSize.height
        detents.closed = screenHeight
        dragOffset = detents.closed
        detents.small = screenHeight * Constants.BottomSheet.shortDetentRatio
    }
}
