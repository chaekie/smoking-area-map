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
    @State private var draggable = false

    var body: some View {
        ZStack {
            if !vm.isScrollingFromTheTop && vm.dragOffset == 0.0 {
                Color.white
            }
            CustomSheetViewControllerRepresentable(vm: vm)
        }
        .offset(y: vm.dragOffset)
        .gesture(draggable ? drag : nil)
        .onAppear() {
            vm.setDetents()
        }
        .onChange(of: isPresented) { isVisible in
            isVisible ? vm.showSmallSheet() : vm.hideSheet()
        }
        .onDisappear() {
            vm.currentDetent = .closed
        }
        .onReceive(vm.$spot) { newSpot in
            if let newSpot = newSpot as? MySpot,
               let _ = newSpot.photo {
                draggable = true
            } else {
                draggable = false
            }
        }
        .shadow(color: !vm.isScrollEnabled ? .black.opacity(0.15) : .clear, radius: 5)
        .ignoresSafeArea()
        .toolbar(vm.currentDetent == .large ? .hidden : .visible)
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
