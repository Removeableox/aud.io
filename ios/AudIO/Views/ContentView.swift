//
//  ContentView.swift
//  AudIO
//
//  Created on Feb 17, 2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "book.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Welcome to AudIO")
                .font(.title)
                .padding()
            Text("An iPhone app for reading EPUBs aloud")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
