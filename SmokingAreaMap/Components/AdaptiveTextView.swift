//
//  AdaptiveTextView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/28/24.
//

import SwiftUI

struct AdaptiveTextView: View {
    let text: String
    private var fontStyle: UIFont?
    private var fontColor: UIColor?

    init(text: String) {
        self.text = text
    }

    var body: some View {
        SingleAxisGeometryReader { width in
            LinebreakText(text: text, 
                          width: width,
                          font: fontStyle,
                          color: fontColor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

extension AdaptiveTextView {
    func fontStyle(_ font: UIFont) -> AdaptiveTextView {
        var view = self
        view.fontStyle = font
        return view
    }

    func fontColor(_ color: UIColor) -> AdaptiveTextView {
        var view = self
        view.fontColor = color
        return view
    }
}

fileprivate struct LinebreakText: UIViewRepresentable {
    let text: String
    let width: CGFloat
    var font: UIFont?
    var color: UIColor?

    private func actualNumberOfLines(label: UILabel) -> Int {
        label.layoutIfNeeded()
        let rect = CGSize(width: self.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = self.text.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font as Any], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
    }

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.lineBreakStrategy = .hangulWordPriority
        label.preferredMaxLayoutWidth = CGFloat(1)
        label.numberOfLines = 1
        if let color {
            label.textColor = color
        }
        if let font {
            label.font = font
        }
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
        uiView.numberOfLines = actualNumberOfLines(label: uiView)
    }
}
