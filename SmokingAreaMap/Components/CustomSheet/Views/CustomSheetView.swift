//
//  CustomSheetView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/5/24.
//

import SwiftUI

struct CustomSheetView: View {
    @ObservedObject var vm: CustomSheetViewModel
    @Binding var isPresented: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if !vm.isScrollingFromTheTop && vm.dragOffset == 0.0 {
                    Color.white
                }
                CustomSheetViewControllerRepresentable(vm: vm)
            }
            .offset(y: vm.dragOffset)
            .gesture(drag)
            .onAppear() {
                vm.screenHeight = proxy.size.height
                vm.setDetents()
            }
            .onChange(of: isPresented) { isVisible in
                isVisible ? vm.showSmallSheet() : vm.hideSheet()
            }
            .shadow(color: !vm.isScrollEnabled ? .black.opacity(0.15) : .clear, radius: 5)
        }
        .ignoresSafeArea()
    }

    private var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                vm.handleDragChange(gesture: gesture)
            }
            .onEnded { gesture in
                vm.handleSheetDetent(gesture: gesture)
            }
    }
}

struct CustomSheetViewControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var vm: CustomSheetViewModel

    func makeUIViewController(context: Context) -> CustomSheetScrollViewController {
        let scrollVC = CustomSheetScrollViewController()
        scrollVC.vm = vm
        return scrollVC
    }

    func updateUIViewController(_ uiViewController: CustomSheetScrollViewController, context: Context) {
        uiViewController.scrollView.isScrollEnabled = vm.isScrollEnabled
    }
}
