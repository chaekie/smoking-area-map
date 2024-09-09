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
            vm.showSheet(detent: isVisible ? .small : .closed)
        }
        .onDisappear() {
            vm.currentDetent = .closed
        }
        .shadow(color: vm.isSheetCoverVisible ? .clear : .black.opacity(0.15), radius: 5)
        .toolbar(vm.isToolbarVisible ? .visible : .hidden)
    }

    private var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                vm.onDragChanged(gesture: gesture)
            }
            .onEnded { gesture in
                vm.onDragEnded(gesture: gesture)
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
