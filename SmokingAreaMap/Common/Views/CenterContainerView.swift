//
//  CenterContainerView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/19/24.
//

import SwiftUI

struct CenterContainerView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                content
                Spacer()
            }
            Spacer()
        }
        .background(Color(UIColor.secondarySystemBackground))
    }
}
