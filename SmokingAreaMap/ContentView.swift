//
//  ContentView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/10/24.
//

import SwiftUI

struct ContentView: View {
    private let env = ProcessInfo.processInfo.environment

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
