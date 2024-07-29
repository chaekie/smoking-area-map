//
//  +View.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/24/24.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func onDismissPrevent(isPresented: Bool,
                          shouldPreventDismissal: Bool,
                          onDismissalAttempt: (() -> Void)? = nil) -> some View {
        ModalView(view: self,
                  isPresented: isPresented,
                  shouldPreventDismissal: shouldPreventDismissal,
                  onDismissalAttempt: onDismissalAttempt)
    }
}
