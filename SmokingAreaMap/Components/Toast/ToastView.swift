//
//  ToastView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/29/24.
//

import SwiftUI

struct ToastView: View {
    var message: String
    var style: ToastStyle
    var buttonLabel: String?
    var buttonAction: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            buildIcon()
            buildMessage()
            if let buttonAction, let buttonLabel {
                Spacer(minLength: 12)
                buildButton(label: buttonLabel, action: buttonAction)
            }
        }
        .apply {
            if buttonLabel == nil {
                $0.padding()
            } else {
                $0.padding(.vertical, 8)
                    .padding(.horizontal)
            }
        }
        .background(.black.opacity(0.7))
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .padding(.horizontal)
    }

    @ViewBuilder 
    private func buildIcon() -> some View {
        if !style.iconFileName.isEmpty {
             Image(systemName: style.iconFileName)
                .foregroundColor(style.themeColor)
        }
    }

    private func buildMessage() -> some View {
        Text(message)
            .font(.callout)
            .foregroundStyle(.white)
    }

    private func buildButton(label: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(.black.opacity(0.8))
                .background(.thinMaterial)
                .cornerRadius(18)
        }
    }
}

struct ToastModifier: ViewModifier {
    @ObservedObject var vm: ToastViewModel

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    buildMainToastView()
                        .offset(y: 32)
                }.animation(.spring(), value: vm.toast)
            )
            .onChange(of: vm.toast) { toast in
                if let toast {
                    vm.showToast(toast)
                }
            }
    }

    @ViewBuilder
    private func buildMainToastView() -> some View {
        if let toast = vm.toast {
            VStack {
                ToastView(message: toast.message,
                          style: toast.style,
                          buttonLabel: toast.buttonLabel) {
                    if let buttonAction = toast.buttonAction {
                        buttonAction()
                    }
                    vm.dismissToast()
                }
                Spacer()
            }
        }
    }
}
