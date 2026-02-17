//
//  ReaderView.swift
//  AudIO
//
//  Created on Feb 17, 2026.
//

import SwiftUI

struct ReaderView: View {
    @StateObject private var viewModel: ReaderViewModel
    
    init(metadata: EPUBMetadata) {
        _viewModel = StateObject(wrappedValue: ReaderViewModel(metadata: metadata))
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else if let chapter = viewModel.currentChapter {
                contentView(chapter: chapter)
            } else {
                emptyStateView
            }
        }
        .navigationTitle(viewModel.bookTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.hasPreviousChapter {
                    Button(action: {
                        viewModel.previousChapter()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                if let chapter = viewModel.currentChapter {
                    Text(chapter.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.hasNextChapter {
                    Button(action: {
                        viewModel.nextChapter()
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
    }
    
    // MARK: - Content View
    
    private func contentView(chapter: Chapter) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Chapter title
                Text(chapter.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 8)
                
                // Chapter content
                Text(chapter.content)
                    .font(.system(size: 18, design: .serif))
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading content...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("Error")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.loadContent()
            }) {
                Text("Retry")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No Content")
                .font(.headline)
            
            Text("Unable to load book content")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    ReaderView(metadata: EPUBMetadata(
        title: "Sample Book",
        author: "Sample Author",
        filePath: "/path/to/book.epub"
    ))
}
