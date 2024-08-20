//
//  CustomSheetView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/5/24.
//

import Combine
import SwiftUI

struct Detents {
    var closed: CGFloat
    var small: CGFloat
    var large: CGFloat
}

enum ScrollDirection {
    case up
    case down
}

struct CustomSheetView: View {
    @Binding var isPresented: Bool
    let detector: CurrentValueSubject<CGFloat, Never>
    let publisher: AnyPublisher<CGFloat, Never>

    @State private var lastOffset = Constants.BottomSheet.initPosition
    @State private var dragOffset = Constants.BottomSheet.initPosition {
        didSet { print("dragOffset", dragOffset) }
    }

    @State private var swipeDirection = ScrollDirection.up {
        didSet { print("swipeDirection", swipeDirection) }
    }
    @State private var isScrollDisabled = true
    @State private var detents = Detents(closed: Constants.BottomSheet.initPosition,
                                         small: Constants.BottomSheet.initPosition,
                                         large: 0)
    @State private var screenHeight = CGFloat.zero


    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented

        let detector = CurrentValueSubject<CGFloat, Never>(0)
        self.publisher = detector
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
        self.detector = detector
    }

    var body: some View {
        GeometryReader { proxy in
            buildContent()
                .offset(y: dragOffset)
                .gesture(drag)
                .onAppear() {
                    screenHeight = proxy.size.height
                    setDetents()
                    showSmallSheet()
                }
                .onChange(of: isPresented) { visible in
                    if visible {
                        showSmallSheet()
                    } else {
                        hideSheet()
                    }
                }
        }
        .ignoresSafeArea()
    }

    private var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                dragOffset = lastOffset + gesture.translation.height
                setSwipeDirection(by: gesture.velocity.height)
                constrainSheetHeight()
            }
            .onEnded { gesture in
                let velocity = gesture.velocity.height
                if isFastSwipeDown(velocity: velocity) {
                    showSmallSheet()
                } else if isFastSwipeUp(velocity: velocity) {
                    showLargeSheet()
                } else {
                    handleSlowSwipe(dragOffset: dragOffset)
                }
                lastOffset = dragOffset
            }
    }

    private func buildScrollContent() -> some View {
        ForEach(0..<50) { num in
            HStack {
                Spacer()
                Button("Row \(num) 닫기") {
                    isPresented.toggle()
                }
                Spacer()
            }
            .frame(height: 50)
            .background(.red.opacity(0.5))
        }
    }

    private func buildContent() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                buildScrollContent()
            }
            .background(GeometryReader {
                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: $0.frame(in: .global).minY)
            })
        }
        .scrollDisabled(isScrollDisabled)
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { detector.send($0) }
        .onReceive(publisher) {
            if isScrollStoppedOnTop(scrollOffset: $0) {
                isScrollDisabled = true
            }
        }
    }

    private func setDetents() {
        detents.closed = screenHeight
        detents.small = screenHeight * 4/5
    }

    private func showSmallSheet() {
        withAnimation(.spring(duration: Constants.BottomSheet.aniDuration)) {
            lastOffset = detents.small
            dragOffset = detents.small
            isScrollDisabled = true
        }
    }

    private func showLargeSheet() {
        withAnimation(.spring(duration: Constants.BottomSheet.aniDuration)) {
            lastOffset = detents.large
            dragOffset = detents.large
            isScrollDisabled = false
        }
    }

    private func hideSheet() {
        withAnimation(.spring(duration: Constants.BottomSheet.aniDuration)) {
            lastOffset = detents.closed
            dragOffset = detents.closed
        }
    }

    private func setSwipeDirection(by velocity: CGFloat) {
        if velocity > 0 {
            swipeDirection = .down
        } else {
            swipeDirection = .up
        }
    }

    private func constrainSheetHeight() {
        if dragOffset > detents.small {
            dragOffset = detents.small
        } else if dragOffset < detents.large {
            dragOffset = detents.large
        }
    }

    private func isFastSwipeDown(velocity: CGFloat) -> Bool {
        return velocity > Constants.BottomSheet.standardVelocity
    }

    private func isFastSwipeUp(velocity: CGFloat) -> Bool {
        return velocity < -Constants.BottomSheet.standardVelocity
    }

    private func shouldExpandSheet(dragOffset: CGFloat) -> Bool {
        return dragOffset < detents.small
    }

    private func shouldCollapseSheet(dragOffset: CGFloat) -> Bool {
        return dragOffset < 100
    }

    private func isScrollStoppedOnTop(scrollOffset: CGFloat) -> Bool {
        return scrollOffset == 0.0
    }

    private func handleSlowSwipe(dragOffset: CGFloat) {
        switch swipeDirection {
        case .up:
            if shouldExpandSheet(dragOffset: dragOffset) {
                showLargeSheet()
            } else {
                showSmallSheet()
            }
        case .down:
            if shouldCollapseSheet(dragOffset: dragOffset) {
                showLargeSheet()
            } else {
                showSmallSheet()
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
