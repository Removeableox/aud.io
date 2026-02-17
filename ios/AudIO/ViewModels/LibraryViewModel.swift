//
//  LibraryViewModel.swift
//  AudIO
//
//  Created on Feb 17, 2026.
//

import Foundation
import SwiftUI

@MainActor
class LibraryViewModel: ObservableObject {
    @Published var showDocumentPicker = false
    @Published var storedEPUBs: [URL] = []
    @Published var importError: String?
    @Published var importSuccessMessage: String?
    
    private let fileManager = EPUBFileManager.shared
    
    init() {
        loadStoredEPUBs()
    }
    
    /// Load all stored EPUB files
    func loadStoredEPUBs() {
        storedEPUBs = fileManager.getStoredEPUBs()
    }
    
    /// Handle document picker completion
    func handleDocumentPicked(url: URL) {
        importError = nil
        importSuccessMessage = nil
        
        let result = fileManager.saveEPUB(from: url)
        
        switch result {
        case .success(let savedURL):
            importSuccessMessage = "EPUB imported successfully: \(savedURL.lastPathComponent)"
            loadStoredEPUBs()
        case .failure(let error):
            importError = error.localizedDescription
        }
    }
    
    /// Show document picker
    func showImportPicker() {
        showDocumentPicker = true
    }
    
    /// Clear import messages
    func clearMessages() {
        importError = nil
        importSuccessMessage = nil
    }
}
