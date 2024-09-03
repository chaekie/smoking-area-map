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
        CustomSheetViewControllerRepresentable(vm: vm)
        .offset(y: vm.dragOffset)
        .gesture(drag)
        .onAppear() {
            vm.setDetents()
        }
        .onChange(of: isPresented) { isVisible in
            isVisible ? vm.showSmallSheet() : vm.hideSheet()
        }
        .onDisappear() {
            vm.currentDetent = .closed
        }
        .shadow(color: vm.isSheetHeaderVisible ? .clear : .black.opacity(0.15), radius: 5)
        .toolbar(vm.isToolbarVisible ? .visible : .hidden)
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
