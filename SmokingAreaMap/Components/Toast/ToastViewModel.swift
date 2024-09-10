//
//  ToastViewModel.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/29/24.
//

import SwiftUI

class ToastViewModel: ObservableObject {
    @Binding var toast: Toast?
    private var workItem: DispatchWorkItem?

    init(toast: Binding<Toast?>) {
        self._toast = toast
    }

    func showToast(_ toast: Toast) {
        self.toast = toast
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if toast.duration > 0 {
            workItem?.cancel()

            let task = DispatchWorkItem {
                self.dismissToast()
            }

            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }

    func dismissToast() {
        withAnimation {
            toast = nil
        }

        workItem?.cancel()
        workItem = nil
    }
}
