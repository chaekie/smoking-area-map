//
//  RoundedBorderView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/19/24.
//

import SwiftUI

struct RoundedBorderView<Content: View>: View {
    let label: String
    let isRequired: Bool
    let content: () -> Content

    init(label: String,
         isRequired: Bool = false,
         @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self.isRequired = isRequired
        self.content = content
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 3) {
                Text(label).bold()
                if isRequired {
                    Text("(필수)")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            content()
                .padding(10)
                .clipShape(
                    RoundedRectangle(cornerRadius: 8)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.gray.opacity(0.5), lineWidth: 1)
                }
        }
    }
}
