//
//  RoundedBorderView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/19/24.
//

import SwiftUI

struct RoundedBorderView<Content: View>: View {
    let label: String
    let content: () -> Content

    init(label: String,
         @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self.content = content
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text(label).bold()
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
