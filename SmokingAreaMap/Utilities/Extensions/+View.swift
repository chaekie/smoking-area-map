//
//  +View.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/24/24.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }

    func onDismissPrevent(isPresented: Bool,
                          shouldPreventDismissal: Bool,
                          onDismissalAttempt: (() -> Void)? = nil) -> some View {
        ModalView(view: self,
                  isPresented: isPresented,
                  shouldPreventDismissal: shouldPreventDismissal,
                  onDismissalAttempt: onDismissalAttempt)
    }

    func toastView(toast: Binding<Toast?>) -> some View {
        let vm = ToastViewModel(toast: toast)
        return self.modifier(ToastModifier(vm: vm))
    }
}
