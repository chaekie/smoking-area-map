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
    @Published var isScrollingDownFromTop = false
    @Published var isSheetHeaderVisible = false
    @Published var isToolbarVisible = true
    @Published var currentDetent = Detent.closed
    @Published var detents = DetentPositions(closed: Constants.BottomSheet.initPosition,
                                             small: Constants.BottomSheet.initPosition,
                                             large: UIScreen.safeAreaInsets.top + Constants.BottomSheet.headerHeight - Constants.BottomSheet.dragIndicatorHeight * 2/3)

    var onShowLargeSheet: (() -> Void)?

    func updateIsSheetHeaderVisibleIfNeeded(condition: Bool) {
        if isSheetHeaderVisible != condition {
            withAnimation(.easeInOut(duration: 0.1)) {
                isSheetHeaderVisible = condition
            }
        }
    }

    func updateIsToolbarVisibleIfNeeded(condition: Bool) {
        if isToolbarVisible != condition {
            withAnimation(.easeInOut(duration: 0.1)) {
                isToolbarVisible = condition
            }
        }
    }

    func handleDragChange(gesture: DragGesture.Value) {
        if !isScrollEnabled {
            let isDragStartAboveSafeArea = gesture.startLocation.y < UIScreen.screenSize.height - UIScreen.safeAreaInsets.bottom
            if isDragStartAboveSafeArea {
                constrainSheetHeight(gesture: gesture)
            }
        }
    }

    private func constrainSheetHeight(gesture: DragGesture.Value) {
        let currentOffset = lastOffset + gesture.translation.height

        if currentOffset >= detents.small {
            updateIsSheetHeaderVisibleIfNeeded(condition: false)
            dragOffset = detents.small
        } else if currentOffset <= detents.large {
            updateIsSheetHeaderVisibleIfNeeded(condition: true)
            dragOffset = detents.large
        } else {
            updateIsSheetHeaderVisibleIfNeeded(condition: false)
            dragOffset = currentOffset
        }
        updateIsToolbarVisibleIfNeeded(condition: currentOffset >= UIScreen.screenSize.height * 1/3)
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

    private func showSheet(detent: Detent,
                           isScrollEnabled: Bool,
                           shouldShowHeader: Bool,
                           shouldShowToolbar: Bool,
                           duration: CGFloat = Constants.BottomSheet.aniDuration) {
        let animation = Animation.linear(duration: duration)

        let updateState = {
            self.lastOffset = detent == .large ? self.detents.large : self.detents.small
            self.dragOffset = detent == .large ? self.detents.large : self.detents.small
            self.currentDetent = detent
            self.isScrollEnabled = isScrollEnabled
            if detent == .large {
                self.onShowLargeSheet?()
            }
        }

        let completion = {
            self.isScrollingDownFromTop = false
            self.updateIsSheetHeaderVisibleIfNeeded(condition: shouldShowHeader)
            self.updateIsToolbarVisibleIfNeeded(condition: shouldShowToolbar)
        }

        if #available(iOS 17.0, *) {
            withAnimation(animation, updateState, completion: completion)
        } else {
            withAnimation(animation, updateState)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: completion)
        }
    }

    func showSmallSheet(duration: CGFloat = Constants.BottomSheet.aniDuration) {
        showSheet(detent: .small, isScrollEnabled: false, shouldShowHeader: false, shouldShowToolbar: true, duration: duration)
    }

    func showLargeSheet(duration: CGFloat = Constants.BottomSheet.aniDuration) {
        showSheet(detent: .large, isScrollEnabled: true, shouldShowHeader: true, shouldShowToolbar: false, duration: duration)
    }

    func hideSheet() {
        self.lastOffset = self.detents.closed
        self.dragOffset = self.detents.closed
        self.currentDetent = .closed
        self.isScrollEnabled = false
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


//withAnimation(.spring(response: Constants.BottomSheet.aniDuration,
//                      dampingFraction: 0.6,
//                      blendDuration: 0)) {
//}
