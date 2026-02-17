//
//  LibraryView.swift
//  AudIO
//
//  Created on Feb 17, 2026.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: LibraryViewModel
    
    // Grid layout: 2 columns on iPhone, 3 on iPad
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.storedEPUBs.isEmpty {
                    emptyStateView
                } else {
                    scrollableGridView
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showImportPicker()
                    }) {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showDocumentPicker) {
                DocumentPickerView(isPresented: $viewModel.showDocumentPicker) { url in
                    viewModel.handleDocumentPicked(url: url)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "books.vertical.fill")
                .imageScale(.large)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Books Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Import your first EPUB to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                viewModel.showImportPicker()
            }) {
                Label("Import EPUB", systemImage: "square.and.arrow.down")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    // MARK: - Grid View
    
    private var scrollableGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.storedEPUBs, id: \.self) { epubURL in
                    EPUBCard(epubURL: epubURL)
                }
            }
            .padding()
        }
    }
}

// MARK: - EPUB Card

struct EPUBCard: View {
    let epubURL: URL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cover placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.1))
                    .aspectRatio(2/3, contentMode: .fit)
                
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.accentColor)
            }
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Title (filename without extension)
            Text(displayTitle)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Subtitle (file size or date)
            Text(fileSizeString)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            // TODO: Navigate to reader view
            print("Tapped EPUB: \(epubURL.lastPathComponent)")
        }
    }
    
    // MARK: - Helpers
    
    private var displayTitle: String {
        let filename = epubURL.lastPathComponent
        let nameWithoutExtension = (filename as NSString).deletingPathExtension
        return nameWithoutExtension
    }
    
    private var fileSizeString: String {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: epubURL.path),
              let fileSize = attributes[.size] as? Int64 else {
            return ""
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}

// MARK: - Preview

#Preview {
    LibraryView(viewModel: LibraryViewModel())
}
