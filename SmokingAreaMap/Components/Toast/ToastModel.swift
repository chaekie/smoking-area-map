//
//  ToastModel.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/29/24.
//

import SwiftUI

struct Toast: Equatable {
    var message: String
    var style: ToastStyle
    var duration: Double = 2
    var buttonLabel: String?
    var buttonAction: (() -> Void)?

    static func == (lhs: Toast, rhs: Toast) -> Bool {
        return lhs.message == rhs.message &&
        lhs.style == rhs.style &&
        lhs.duration == rhs.duration &&
        lhs.buttonLabel == rhs.buttonLabel
    }
}

enum ToastStyle {
    case info
    case success
    case warning
    case error
}

extension ToastStyle {
    var themeColor: Color {
        switch self {
        case .info: return .clear
        case .success: return .green
        case .warning: return .orange
        case .error: return .red
        }
    }

    var iconFileName: String {
        switch self {
        case .info: return ""
        case .success: return "checkmark.circle.fill"
        case .warning: return "info.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}
