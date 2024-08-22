//
//  CustomSheetView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/5/24.
//

import SwiftUI

struct CustomSheetView: View {
    @StateObject var vm = CustomSheetViewModel()
    @Binding var isPresented: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if !vm.isScrollingFromTheTop && vm.dragOffset == 0.0 {
                    Color.white
                }
                ScrollViewControllerRepresentable(isPresented: $isPresented)
            }
            .environmentObject(vm)
            .offset(y: vm.dragOffset)
            .gesture(drag)
            .onAppear() {
                vm.screenHeight = proxy.size.height
                vm.setDetents()
                vm.showSmallSheet()
            }
            .onChange(of: isPresented) { visible in
                if visible {
                    vm.showSmallSheet()
                } else {
                    vm.hideSheet()
                }
            }
        }
        .ignoresSafeArea()
    }

    private var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if !vm.isScrollEnabled {
                    vm.dragOffset = vm.lastOffset + gesture.translation.height
                }
                vm.setSwipeDirection(by: gesture.velocity.height)
                vm.constrainSheetHeight()
            }
            .onEnded { gesture in
                let velocity = gesture.velocity.height
                vm.handleSwipe(velocity: velocity)
            }
    }
}
