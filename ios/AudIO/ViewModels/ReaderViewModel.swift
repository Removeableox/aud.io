//
//  ReaderViewModel.swift
//  AudIO
//
//  Created on Feb 17, 2026.
//

import Foundation
import SwiftUI

@MainActor
class ReaderViewModel: ObservableObject {
    @Published var currentChapter: Chapter?
    @Published var chapters: [Chapter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentChapterIndex: Int = 0
    
    private let metadata: EPUBMetadata
    
    init(metadata: EPUBMetadata) {
        self.metadata = metadata
        loadContent()
    }
    
    /// Load EPUB content
    /// This is a placeholder method that will be enhanced when EPUB parsing service is implemented
    func loadContent() {
        isLoading = true
        errorMessage = nil
        
        // TODO: When EPUBParserService is implemented, call it here:
        // let parser = EPUBParserService.shared
        // let result = parser.parseEPUB(metadata: metadata)
        // switch result {
        // case .success(let parsedChapters):
        //     chapters = parsedChapters
        //     currentChapter = chapters.first
        //     currentChapterIndex = 0
        // case .failure(let error):
        //     errorMessage = "Failed to load content: \(error.localizedDescription)"
        // }
        
        // Placeholder: Create a sample chapter for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let placeholderChapter = Chapter(
                title: "Chapter 1",
                content: """
                This is placeholder content. EPUB parsing will be implemented soon.
                
                Once the EPUB parsing service is available, this reader view will display the actual content from your EPUB file.
                
                You can scroll through the text, and when chapter navigation is implemented, you'll be able to move between chapters.
                """,
                index: 0,
                bookId: self.metadata.id
            )
            self.chapters = [placeholderChapter]
            self.currentChapter = placeholderChapter
            self.currentChapterIndex = 0
            self.isLoading = false
        }
    }
    
    /// Navigate to a specific chapter by index
    /// - Parameter index: The index of the chapter to navigate to
    func navigateToChapter(index: Int) {
        guard index >= 0 && index < chapters.count else {
            return
        }
        
        currentChapterIndex = index
        currentChapter = chapters[index]
    }
    
    /// Navigate to the next chapter
    func nextChapter() {
        guard currentChapterIndex < chapters.count - 1 else {
            return
        }
        
        navigateToChapter(index: currentChapterIndex + 1)
    }
    
    /// Navigate to the previous chapter
    func previousChapter() {
        guard currentChapterIndex > 0 else {
            return
        }
        
        navigateToChapter(index: currentChapterIndex - 1)
    }
    
    /// Check if there is a next chapter
    var hasNextChapter: Bool {
        currentChapterIndex < chapters.count - 1
    }
    
    /// Check if there is a previous chapter
    var hasPreviousChapter: Bool {
        currentChapterIndex > 0
    }
    
    /// Get the book title for display
    var bookTitle: String {
        metadata.displayTitle
    }
}
