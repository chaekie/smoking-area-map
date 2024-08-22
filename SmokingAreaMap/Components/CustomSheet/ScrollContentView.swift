//
//  ScrollContentView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/22/24.
//

import SwiftUI

struct ScrollContentView: View {
    @Binding var isPresented: Bool
    var collapseSheet: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<50) { num in
                HStack {
                    Spacer()
                    Button("Row \(num) 닫기") {
                        collapseSheet()
                    }
                    Spacer()
                }
                .frame(height: 50)
                .background(.red.opacity(0.5))
            }
        }
    }
}
