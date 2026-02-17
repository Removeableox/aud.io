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
        VStack(spacing: 20) {
            Image(systemName: "book.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Welcome to AudIO")
                .font(.title)
            Text("An iPhone app for reading EPUBs aloud")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button(action: {
                viewModel.showImportPicker()
            }) {
                Label("Import EPUB", systemImage: "square.and.arrow.down")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            if let error = viewModel.importError {
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            if let successMessage = viewModel.importSuccessMessage {
                Text(successMessage)
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal)
            }
            
            if !viewModel.storedEPUBs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stored EPUBs (\(viewModel.storedEPUBs.count))")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(viewModel.storedEPUBs, id: \.self) { url in
                        Text(url.lastPathComponent)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
        }
        .padding()
        .sheet(isPresented: $viewModel.showDocumentPicker) {
            DocumentPickerView(isPresented: $viewModel.showDocumentPicker) { url in
                viewModel.handleDocumentPicked(url: url)
            }
        }
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
