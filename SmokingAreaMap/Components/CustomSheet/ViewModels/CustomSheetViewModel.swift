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
    @Published var currentDetent = Detent.closed
    @Published var detents = DetentPositions(closed: Constants.BottomSheet.initPosition,
                                             small: Constants.BottomSheet.initPosition,
                                             large: UIScreen.safeAreaInsets.top + Constants.BottomSheet.headerHeight - Constants.BottomSheet.dragIndicatorHeight * 2/3)

    @Published var isSheetCollapsing = false
    @Published var isSheetCoverVisible = false
    @Published var isToolbarVisible = true
    @Published var isTitleVisible = false

    private let safeAreaBottomRange = UIScreen.screenSize.height - UIScreen.safeAreaInsets.bottom
    var onShowLargeSheet: (() -> Void)?
    var onShowSmallSheet: (() -> Void)?

    func onDragChanged(gesture: DragGesture.Value) {
        if !isScrollEnabled {
            let isDragStartAboveSafeAreaBottom = gesture.startLocation.y < safeAreaBottomRange
            if isDragStartAboveSafeAreaBottom {
                let newOffset = getConstrainedOffset(gesture: gesture)
                dragOffset = newOffset
                updateVisibilityBasedOnDragOffset(offset: newOffset)
            }
        }
    }

    private func getConstrainedOffset(gesture: DragGesture.Value) -> CGFloat {
        let currentOffset = lastOffset + gesture.translation.height

        if currentOffset >= detents.small {
            return detents.small
        } else if currentOffset <= detents.large {
            return detents.large
        } else {
            return currentOffset
        }
    }

    func updateVisibilityBasedOnDragOffset(offset: CGFloat) {
        let shouldShowToolbar = offset > Constants.BottomSheet.toolbarVisibilityThreshold
        let shouldShowSheetCover = offset <= self.detents.large
        withAnimation(.easeInOut(duration: Constants.BottomSheet.aniDuration)) {
            updateVisibilityIfNeeded(currentValue: &isToolbarVisible, newValue: shouldShowToolbar)
            updateVisibilityIfNeeded(currentValue: &isSheetCoverVisible, newValue: shouldShowSheetCover)
        }
    }

    func updateTitleVisibility(offset: CGFloat) {
        let shouldShowTitle = offset > Constants.BottomSheet.dragIndicatorHeight + UIFont.preferredFont(forTextStyle: .title2).pointSize
        updateVisibilityIfNeeded(currentValue: &isTitleVisible, newValue: shouldShowTitle)
    }

    func updateIsSheetCollapsing(offset: CGFloat, startOffset: CGFloat) {
        let isScrollingDownFromTop = startOffset <= 0 && (offset < startOffset)
        updateVisibilityIfNeeded(currentValue: &self.isSheetCollapsing, newValue: isScrollingDownFromTop)
    }

    func updateVisibilityIfNeeded<T: Equatable>(currentValue: inout T, newValue: T) {
        if currentValue != newValue {
            currentValue = newValue
        }
    }

    func onDragEnded(gesture: DragGesture.Value) {
        let velocity = gesture.velocity.height
        let isFastSwipeUp = velocity < -Constants.BottomSheet.dragVelocityThreshold
        let isFastSwipeDown = velocity > Constants.BottomSheet.dragVelocityThreshold
        let distance = gesture.translation.height

        if isFastSwipeDown {
            showSheet(detent: .small)
        } else if isFastSwipeUp {
            showSheet(detent: .large)
        } else {
            handleSlowSwipe(distance: distance)
        }

        lastOffset = dragOffset
    }

    func showSheet(detent: Detent, duration: CGFloat = Constants.BottomSheet.aniDuration) {
        let detentOffset = self.getDetentOffset(for: detent)
        let animation = Animation.linear(duration: duration)

        let updateState = {
            self.updateStateForDetent(detent, detentOffset: detentOffset)
        }

        let completion = {
            self.handleVisibilityUpdates(detentOffset: detentOffset)
        }

        performAnimation(animation, updateState: updateState, completion: completion, detent: detent, duration: duration)
    }

    private func updateStateForDetent(_ detent: Detent, detentOffset: CGFloat) {
        self.lastOffset = detentOffset
        self.dragOffset = detentOffset
        self.currentDetent = detent
        self.isScrollEnabled = (detent == .large)

        switch detent {
        case .small: self.onShowSmallSheet?()
        case .large: self.onShowLargeSheet?()
        default: break
        }
    }

    private func handleVisibilityUpdates(detentOffset: CGFloat) {
        self.isSheetCollapsing = false
        updateVisibilityBasedOnDragOffset(offset: detentOffset)
    }

    private func performAnimation(_ animation: Animation,
                                  updateState: @escaping () -> Void,
                                  completion: @escaping () -> Void,
                                  detent: Detent,
                                  duration: CGFloat) {
        if detent == .large {
            if #available(iOS 17.0, *) {
                withAnimation(animation, updateState, completion: completion)
            } else {
                withAnimation(animation, updateState)
                DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: completion)
            }
        } else {
            handleVisibilityUpdates(detentOffset: getDetentOffset(for: detent))
            withAnimation(animation, updateState)
        }
    }

    private func getDetentOffset(for detent: Detent) -> CGFloat {
        switch detent {
        case .closed:
            return detents.closed
        case .small:
            return detents.small
        case .large:
            return detents.large
        }
    }

    private func handleSlowSwipe(distance: CGFloat) {
        let isInThresholdRange = abs(distance) < Constants.BottomSheet.smallToLargeDistanceThreshold

        switch currentDetent {
        case .small:
            showSheet(detent: isInThresholdRange ? .small : .large)
        case .large:
            showSheet(detent: isInThresholdRange ? .large : .small)
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
