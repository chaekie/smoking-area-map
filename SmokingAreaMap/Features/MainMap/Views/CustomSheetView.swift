//
//  CustomSheetView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/5/24.
//

import SwiftUI

struct Detents {
    var closed: CGFloat
    var small: CGFloat
    var full: CGFloat
}

enum ScrollDirection {
    case up
    case down
}

struct CustomSheetView: View {
    @Binding var isPresented: Bool
    @State private var oldOffsetY = CGFloat(10000)
    @State private var newOffsetY = CGFloat(10000)
    @State private var accumulatedYOffset = CGFloat(10000)
    @State private var detents: Detents?
    @State private var scrollDirection = ScrollDirection.up

    var body: some View {
        GeometryReader { geo in
            let screenHeight = geo.size.height

            ZStack {
                Color.green.opacity(0.5)
                    .onChange(of: isPresented) { _ in
                        detents = Detents(closed: screenHeight,
                                          small: screenHeight * 3/4,
                                          full: 0)
                    }

                buildContent()
            }
        }
        .onChange(of: isPresented, perform: { newValue in
            togglePresent(newValue)
        })
        .offset(y: newOffsetY)
        .gesture(drag)
        .ignoresSafeArea()
    }

    var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                handleScrollDirection(gesture)
                if let detents {
                    if newOffsetY > detents.small {
                        newOffsetY = detents.small
                    }
                }

            }
            .onEnded { gesture in
                let velocity = gesture.velocity.height

                if let detents {
                    if velocity > 1000 {
                        setSmallDetent(detents)
                    } else if velocity < -1000 {
                        setFullDetent(detents)
                    } else {
                        switch scrollDirection {
                        case .up:
                            if newOffsetY > detents.closed * 2/3 {
                                setSmallDetent(detents)
                            } else {
                                setFullDetent(detents)
                            }
                        case .down:
                            if newOffsetY < detents.closed * 1/3 {
                                setFullDetent(detents)
                            } else {
                                setSmallDetent(detents)
                            }
                        }
                    }
                } else {
                    accumulatedYOffset = newOffsetY
                }
            }
    }

    private func setSmallDetent(_ detents: Detents) {
        withAnimation(.linear(duration: 0.05)) {
            newOffsetY = detents.small
            accumulatedYOffset = detents.small
        }
    }

    private func setFullDetent(_ detents: Detents) {
        withAnimation(.linear(duration: 0.05)) {
            newOffsetY = detents.full
            accumulatedYOffset = detents.full
        }
    }

    private func togglePresent(_ newValue: Bool) {
        if let detents {
            if newValue {
                oldOffsetY = detents.small
                newOffsetY = detents.small
                accumulatedYOffset = detents.small
            } else {
                oldOffsetY = detents.closed
                newOffsetY = detents.closed
                accumulatedYOffset = detents.closed
            }
        }
    }

    private func handleScrollDirection(_ gesture: DragGesture.Value) {
        newOffsetY = accumulatedYOffset + gesture.translation.height
        if oldOffsetY > newOffsetY {
            scrollDirection = .up
        } else {
            scrollDirection = .down
        }
        oldOffsetY = accumulatedYOffset + gesture.translation.height
    }

    private func buildContent() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(0..<50) {
                    Button("Row \($0) 닫기") {
                        isPresented.toggle()
                    }
                }
            }
        }
    }
}
