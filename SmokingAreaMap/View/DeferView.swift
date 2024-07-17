//
//  DeferView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/17/24.
//

import SwiftUI

struct DeferView<Content: View>: View {
    let content: () -> Content

    init(_ content: @autoclosure @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        content()
    }
}

