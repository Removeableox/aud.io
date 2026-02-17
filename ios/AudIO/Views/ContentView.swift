//
//  ContentView.swift
//  AudIO
//
//  Created on Feb 17, 2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LibraryViewModel()
    
    var body: some View {
        LibraryView(viewModel: viewModel)
            .onChange(of: viewModel.importError) { _ in
                if viewModel.importError != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        viewModel.clearMessages()
                    }
                }
            }
            .onChange(of: viewModel.importSuccessMessage) { _ in
                if viewModel.importSuccessMessage != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        viewModel.clearMessages()
                    }
                }
            }
    }
}

#Preview {
    ContentView()
}
