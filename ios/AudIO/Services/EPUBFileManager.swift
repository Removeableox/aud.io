//
//  EPUBFileManager.swift
//  AudIO
//
//  Created on Feb 17, 2026.
//

import Foundation

enum EPUBFileManagerError: LocalizedError {
    case documentsDirectoryNotFound
    case directoryCreationFailed
    case fileCopyFailed(Error)
    case fileNotFound
    case invalidURL
    case duplicateFile
    
    var errorDescription: String? {
        switch self {
        case .documentsDirectoryNotFound:
            return "Documents directory not found"
        case .directoryCreationFailed:
            return "Failed to create EPUBs directory"
        case .fileCopyFailed(let error):
            return "Failed to copy file: \(error.localizedDescription)"
        case .fileNotFound:
            return "File not found"
        case .invalidURL:
            return "Invalid file URL"
        case .duplicateFile:
            return "A file with this name already exists"
        }
    }
}

class EPUBFileManager {
    static let shared = EPUBFileManager()
    
    private let fileManager = FileManager.default
    private let epubDirectoryName = "EPUBs"
    
    private init() {}
    
    /// Get the EPUBs directory URL, creating it if it doesn't exist
    func getEPUBsDirectory() throws -> URL {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw EPUBFileManagerError.documentsDirectoryNotFound
        }
        
        let epubDirectory = documentsDirectory.appendingPathComponent(epubDirectoryName, isDirectory: true)
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: epubDirectory.path) {
            do {
                try fileManager.createDirectory(at: epubDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw EPUBFileManagerError.directoryCreationFailed
            }
        }
        
        return epubDirectory
    }
    
    /// Save an EPUB file from the imported URL to the Documents directory
    /// - Parameter url: The URL of the imported EPUB file
    /// - Parameter allowDuplicates: If false, rejects files with duplicate names. Default is false.
    /// - Returns: Result containing the destination URL on success, or an error on failure
    func saveEPUB(from url: URL, allowDuplicates: Bool = false) -> Result<URL, Error> {
        // Ensure we can access the file
        guard url.startAccessingSecurityScopedResource() else {
            return .failure(EPUBFileManagerError.invalidURL)
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let epubDirectory = try getEPUBsDirectory()
            let originalFilename = url.lastPathComponent
            
            // Check for duplicates if not allowed
            if !allowDuplicates && isDuplicate(filename: originalFilename) {
                return .failure(EPUBFileManagerError.duplicateFile)
            }
            
            // Use original filename if duplicates allowed, otherwise generate unique name
            let filename = allowDuplicates ? originalFilename : generateUniqueFilename(from: originalFilename)
            let destinationURL = epubDirectory.appendingPathComponent(filename)
            
            // Copy file to destination
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            try fileManager.copyItem(at: url, to: destinationURL)
            
            return .success(destinationURL)
        } catch {
            if let epubError = error as? EPUBFileManagerError {
                return .failure(epubError)
            }
            return .failure(EPUBFileManagerError.fileCopyFailed(error))
        }
    }
    
    /// Delete an EPUB file
    /// - Parameter url: The URL of the EPUB file to delete
    /// - Returns: Result indicating success or failure
    func deleteEPUB(at url: URL) -> Result<Void, Error> {
        guard fileExists(at: url) else {
            return .failure(EPUBFileManagerError.fileNotFound)
        }
        
        do {
            try fileManager.removeItem(at: url)
            return .success(())
        } catch {
            return .failure(EPUBFileManagerError.fileCopyFailed(error))
        }
    }
    
    /// Retrieve all stored EPUB file URLs
    /// - Returns: Array of URLs for all stored EPUB files
    func getStoredEPUBs() -> [URL] {
        guard let epubDirectory = try? getEPUBsDirectory() else {
            return []
        }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: epubDirectory,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
            
            // Filter to only EPUB files
            return fileURLs.filter { url in
                url.pathExtension.lowercased() == "epub"
            }
        } catch {
            return []
        }
    }
    
    /// Check if a file exists at the given URL
    /// - Parameter url: The URL to check
    /// - Returns: True if the file exists, false otherwise
    func fileExists(at url: URL) -> Bool {
        return fileManager.fileExists(atPath: url.path)
    }
    
    /// Check if a file with the given filename already exists (duplicate check)
    /// - Parameter filename: The filename to check
    /// - Returns: True if a file with this name exists, false otherwise
    func isDuplicate(filename: String) -> Bool {
        guard let epubDirectory = try? getEPUBsDirectory() else {
            return false
        }
        
        let fileURL = epubDirectory.appendingPathComponent(filename)
        return fileExists(at: fileURL)
    }
    
    /// Generate a unique filename to avoid conflicts
    /// - Parameter originalFilename: The original filename
    /// - Returns: A unique filename with UUID prefix if needed
    private func generateUniqueFilename(from originalFilename: String) -> String {
        let epubDirectory: URL
        do {
            epubDirectory = try getEPUBsDirectory()
        } catch {
            // If we can't get directory, just use UUID prefix
            return "\(UUID().uuidString)_\(originalFilename)"
        }
        
        let fileExtension = (originalFilename as NSString).pathExtension
        let nameWithoutExtension = (originalFilename as NSString).deletingPathExtension
        
        var filename = originalFilename
        var counter = 1
        
        // Check if file exists, and if so, append a number
        while fileExists(at: epubDirectory.appendingPathComponent(filename)) {
            filename = "\(nameWithoutExtension)_\(counter).\(fileExtension)"
            counter += 1
        }
        
        return filename
    }
}
