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
    @Published var epubMetadata: [EPUBMetadata] = []
    @Published var importError: String?
    @Published var importSuccessMessage: String?
    @Published var selectedMetadata: EPUBMetadata?
    @Published var showRenameSheet = false
    @Published var showImagePicker = false
    @Published var showCropView = false
    @Published var imageToCrop: UIImage?
    @Published var showDeleteConfirmation = false
    @Published var metadataToDelete: EPUBMetadata?
    
    private let fileManager = EPUBFileManager.shared
    private let metadataService = MetadataService.shared
    private let coverManager = CoverImageManager.shared
    
    init() {
        loadMetadata()
        // Migrate existing EPUBs on first launch
        migrateIfNeeded()
    }
    
    /// Load all metadata from storage
    func loadMetadata() {
        var loadedMetadata = metadataService.loadMetadata()
        
        // Validate and clean up cover paths - remove paths for files that don't exist
        var needsUpdate = false
        for index in loadedMetadata.indices {
            if let coverPath = loadedMetadata[index].coverImagePath {
                // #region agent log
                let logPath = "/Users/calebcosta/coding/aud.io/.cursor/debug.log"
                let fileExists = FileManager.default.fileExists(atPath: coverPath)
                let coverManagerURL = coverManager.getCoverURL(forBookId: loadedMetadata[index].id)
                let coverManagerExists = coverManagerURL != nil
                if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.loadMetadata\",\"message\":\"Validating cover path\",\"data\":{\"bookId\":\"\(loadedMetadata[index].id.uuidString)\",\"coverImagePath\":\"\(coverPath)\",\"fileExists\":\(fileExists),\"coverManagerURL\":\"\(coverManagerURL?.path ?? "nil")\",\"coverManagerExists\":\(coverManagerExists)},\"runId\":\"run1\",\"hypothesisId\":\"B\"}\n".data(using: .utf8),
                   let fileHandle = FileHandle(forWritingAtPath: logPath) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(logData)
                    fileHandle.closeFile()
                } else if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.loadMetadata\",\"message\":\"Validating cover path\",\"data\":{\"bookId\":\"\(loadedMetadata[index].id.uuidString)\",\"coverImagePath\":\"\(coverPath)\",\"fileExists\":\(fileExists),\"coverManagerURL\":\"\(coverManagerURL?.path ?? "nil")\",\"coverManagerExists\":\(coverManagerExists)},\"runId\":\"run1\",\"hypothesisId\":\"B\"}\n".data(using: .utf8) {
                    try? logData.write(to: URL(fileURLWithPath: logPath), options: [])
                }
                // #endregion
                
                // Check if file exists at stored path, or if CoverImageManager can find it
                let fileExistsAtPath = FileManager.default.fileExists(atPath: coverPath)
                let fileExistsViaManager = coverManager.coverExists(forBookId: loadedMetadata[index].id)
                
                if !fileExistsAtPath && !fileExistsViaManager {
                    // Cover file doesn't exist, clear the path
                    loadedMetadata[index].coverImagePath = nil
                    needsUpdate = true
                    
                    // #region agent log
                    if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.loadMetadata\",\"message\":\"Clearing invalid cover path\",\"data\":{\"bookId\":\"\(loadedMetadata[index].id.uuidString)\",\"coverPath\":\"\(coverPath)\"},\"runId\":\"run1\",\"hypothesisId\":\"B\"}\n".data(using: .utf8),
                       let fileHandle = FileHandle(forWritingAtPath: logPath) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(logData)
                        fileHandle.closeFile()
                    } else if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.loadMetadata\",\"message\":\"Clearing invalid cover path\",\"data\":{\"bookId\":\"\(loadedMetadata[index].id.uuidString)\",\"coverPath\":\"\(coverPath)\"},\"runId\":\"run1\",\"hypothesisId\":\"B\"}\n".data(using: .utf8) {
                        try? logData.write(to: URL(fileURLWithPath: logPath), options: [])
                    }
                    // #endregion
                } else if !fileExistsAtPath && fileExistsViaManager {
                    // File exists but path is wrong - update with correct path from CoverImageManager
                    if let correctURL = coverManager.getCoverURL(forBookId: loadedMetadata[index].id) {
                        loadedMetadata[index].coverImagePath = correctURL.path
                        needsUpdate = true
                        
                        // #region agent log
                        if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.loadMetadata\",\"message\":\"Fixing cover path\",\"data\":{\"bookId\":\"\(loadedMetadata[index].id.uuidString)\",\"oldPath\":\"\(coverPath)\",\"newPath\":\"\(correctURL.path)\"},\"runId\":\"run1\",\"hypothesisId\":\"B\"}\n".data(using: .utf8),
                           let fileHandle = FileHandle(forWritingAtPath: logPath) {
                            fileHandle.seekToEndOfFile()
                            fileHandle.write(logData)
                            fileHandle.closeFile()
                        } else if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.loadMetadata\",\"message\":\"Fixing cover path\",\"data\":{\"bookId\":\"\(loadedMetadata[index].id.uuidString)\",\"oldPath\":\"\(coverPath)\",\"newPath\":\"\(correctURL.path)\"},\"runId\":\"run1\",\"hypothesisId\":\"B\"}\n".data(using: .utf8) {
                            try? logData.write(to: URL(fileURLWithPath: logPath), options: [])
                        }
                        // #endregion
                    }
                }
            }
        }
        
        // Update metadata if we cleaned up any invalid paths
        if needsUpdate {
            do {
                try metadataService.saveMetadata(loadedMetadata)
            } catch {
                print("Failed to update metadata after cleanup: \(error.localizedDescription)")
            }
        }
        
        epubMetadata = loadedMetadata
    }
    
    /// Migrate existing EPUB files to metadata system if needed
    private func migrateIfNeeded() {
        let epubURLs = fileManager.getStoredEPUBs()
        let existingFilePaths = Set(epubMetadata.map { $0.filePath })
        
        // Check if there are EPUBs without metadata
        let needsMigration = epubURLs.contains { url in
            !existingFilePaths.contains(url.path)
        }
        
        if needsMigration {
            do {
                try metadataService.migrateExistingEPUBs()
                loadMetadata()
            } catch {
                print("Migration error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Handle document picker completion
    func handleDocumentPicked(url: URL) {
        importError = nil
        importSuccessMessage = nil
        
        let filename = url.lastPathComponent
        
        // Check for duplicate filename
        if fileManager.isDuplicate(filename: filename) {
            importError = "A file with the name '\(filename)' already exists. Please rename the file or choose a different one."
            return
        }
        
        // Save EPUB file
        let result = fileManager.saveEPUB(from: url, allowDuplicates: false)
        
        switch result {
        case .success(let savedURL):
            // Create metadata entry
            let title = (filename as NSString).deletingPathExtension
            let metadata = EPUBMetadata(
                title: title,
                filePath: savedURL.path,
                importDate: Date()
            )
            
            // Save metadata
            do {
                try metadataService.addMetadata(metadata)
                importSuccessMessage = "EPUB imported successfully: \(filename)"
                loadMetadata()
            } catch {
                // If metadata save fails, delete the file
                _ = fileManager.deleteEPUB(at: savedURL)
                importError = "Failed to save metadata: \(error.localizedDescription)"
            }
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
    
    /// Rename a book
    /// - Parameters:
    ///   - id: The UUID of the book
    ///   - newTitle: The new custom title
    func renameBook(id: UUID, newTitle: String) {
        guard var metadata = metadataService.getMetadata(id: id) else {
            return
        }
        
        metadata.customTitle = newTitle.isEmpty ? nil : newTitle
        
        do {
            try metadataService.updateMetadata(metadata)
            loadMetadata()
        } catch {
            importError = "Failed to rename book: \(error.localizedDescription)"
        }
    }
    
    /// Delete a book (metadata, cover, and EPUB file)
    /// - Parameter id: The UUID of the book to delete
    func deleteBook(id: UUID) {
        guard let metadata = metadataService.getMetadata(id: id) else {
            return
        }
        
        // Delete EPUB file
        let fileURL = URL(fileURLWithPath: metadata.filePath)
        _ = fileManager.deleteEPUB(at: fileURL)
        
        // Delete cover image
        coverManager.deleteCover(forBookId: id)
        
        // Delete metadata
        do {
            try metadataService.deleteMetadata(id: id)
            loadMetadata()
        } catch {
            importError = "Failed to delete book: \(error.localizedDescription)"
        }
    }
    
    /// Add cover image for a book
    /// - Parameters:
    ///   - id: The UUID of the book
    ///   - image: The UIImage to save as cover
    func addCover(id: UUID, image: UIImage) {
        // #region agent log
        let logPath = "/Users/calebcosta/coding/aud.io/.cursor/debug.log"
        if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.addCover\",\"message\":\"Saving cover\",\"data\":{\"bookId\":\"\(id.uuidString)\"},\"runId\":\"run1\",\"hypothesisId\":\"A\"}\n".data(using: .utf8),
           let fileHandle = FileHandle(forWritingAtPath: logPath) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(logData)
            fileHandle.closeFile()
        } else if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.addCover\",\"message\":\"Saving cover\",\"data\":{\"bookId\":\"\(id.uuidString)\"},\"runId\":\"run1\",\"hypothesisId\":\"A\"}\n".data(using: .utf8) {
            try? logData.write(to: URL(fileURLWithPath: logPath), options: [])
        }
        // #endregion
        
        let result = coverManager.saveCover(image: image, forBookId: id)
        
        switch result {
        case .success(let coverURL):
            // #region agent log
            if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.addCover\",\"message\":\"Cover saved successfully\",\"data\":{\"coverPath\":\"\(coverURL.path)\",\"fileExists\":\(FileManager.default.fileExists(atPath: coverURL.path))},\"runId\":\"run1\",\"hypothesisId\":\"A\"}\n".data(using: .utf8),
               let fileHandle = FileHandle(forWritingAtPath: logPath) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(logData)
                fileHandle.closeFile()
            } else if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.addCover\",\"message\":\"Cover saved successfully\",\"data\":{\"coverPath\":\"\(coverURL.path)\",\"fileExists\":\(FileManager.default.fileExists(atPath: coverURL.path))},\"runId\":\"run1\",\"hypothesisId\":\"A\"}\n".data(using: .utf8) {
                try? logData.write(to: URL(fileURLWithPath: logPath), options: [])
            }
            // #endregion
            
            // Update metadata with cover path
            guard var metadata = metadataService.getMetadata(id: id) else {
                // #region agent log
                if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.addCover\",\"message\":\"Metadata not found\",\"data\":{\"bookId\":\"\(id.uuidString)\"},\"runId\":\"run1\",\"hypothesisId\":\"C\"}\n".data(using: .utf8),
                   let fileHandle = FileHandle(forWritingAtPath: logPath) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(logData)
                    fileHandle.closeFile()
                } else if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.addCover\",\"message\":\"Metadata not found\",\"data\":{\"bookId\":\"\(id.uuidString)\"},\"runId\":\"run1\",\"hypothesisId\":\"C\"}\n".data(using: .utf8) {
                    try? logData.write(to: URL(fileURLWithPath: logPath), options: [])
                }
                // #endregion
                return
            }
            
            metadata.coverImagePath = coverURL.path
            
            // #region agent log
            if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.addCover\",\"message\":\"Updating metadata with cover path\",\"data\":{\"coverImagePath\":\"\(coverURL.path)\"},\"runId\":\"run1\",\"hypothesisId\":\"C\"}\n".data(using: .utf8),
               let fileHandle = FileHandle(forWritingAtPath: logPath) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(logData)
                fileHandle.closeFile()
            } else if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryViewModel.addCover\",\"message\":\"Updating metadata with cover path\",\"data\":{\"coverImagePath\":\"\(coverURL.path)\"},\"runId\":\"run1\",\"hypothesisId\":\"C\"}\n".data(using: .utf8) {
                try? logData.write(to: URL(fileURLWithPath: logPath), options: [])
            }
            // #endregion
            
            do {
                try metadataService.updateMetadata(metadata)
                loadMetadata()
            } catch {
                importError = "Failed to update cover: \(error.localizedDescription)"
            }
        case .failure(let error):
            importError = "Failed to save cover: \(error.localizedDescription)"
        }
    }
    
    /// Prepare rename sheet for a book
    /// - Parameter metadata: The metadata of the book to rename
    func prepareRename(for metadata: EPUBMetadata) {
        selectedMetadata = metadata
        showRenameSheet = true
    }
    
    /// Prepare image picker for a book
    /// - Parameter metadata: The metadata of the book to add cover to
    func prepareAddCover(for metadata: EPUBMetadata) {
        selectedMetadata = metadata
        showImagePicker = true
    }
    
    /// Handle image selected from picker - show crop view
    /// - Parameter image: The selected image
    func handleImageSelected(_ image: UIImage) {
        imageToCrop = image
        showImagePicker = false
        showCropView = true
    }
    
    /// Handle cropped image - save it
    /// - Parameter image: The cropped image
    func handleImageCropped(_ image: UIImage) {
        guard let metadata = selectedMetadata else { return }
        addCover(id: metadata.id, image: image)
        imageToCrop = nil
        showCropView = false
    }
    
    /// Cancel crop view
    func cancelCrop() {
        imageToCrop = nil
        showCropView = false
    }
    
    /// Prepare delete confirmation for a book
    /// - Parameter metadata: The metadata of the book to delete
    func prepareDelete(for metadata: EPUBMetadata) {
        metadataToDelete = metadata
        showDeleteConfirmation = true
    }
    
    /// Confirm deletion of prepared book
    func confirmDelete() {
        guard let metadata = metadataToDelete else { return }
        deleteBook(id: metadata.id)
        metadataToDelete = nil
        showDeleteConfirmation = false
    }
}
