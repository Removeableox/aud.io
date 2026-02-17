//
//  MetadataService.swift
//  AudIO
//
//  Created on Feb 17, 2026.
//

import Foundation

enum MetadataServiceError: LocalizedError {
    case documentsDirectoryNotFound
    case fileReadFailed(Error)
    case fileWriteFailed(Error)
    case invalidJSON
    case metadataNotFound
    
    var errorDescription: String? {
        switch self {
        case .documentsDirectoryNotFound:
            return "Documents directory not found"
        case .fileReadFailed(let error):
            return "Failed to read metadata: \(error.localizedDescription)"
        case .fileWriteFailed(let error):
            return "Failed to save metadata: \(error.localizedDescription)"
        case .invalidJSON:
            return "Invalid metadata format"
        case .metadataNotFound:
            return "Metadata not found"
        }
    }
}

class MetadataService {
    static let shared = MetadataService()
    
    private let fileManager = FileManager.default
    private let metadataFileName = "metadata.json"
    
    private init() {}
    
    /// Get the metadata file URL
    private func getMetadataFileURL() throws -> URL {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw MetadataServiceError.documentsDirectoryNotFound
        }
        return documentsDirectory.appendingPathComponent(metadataFileName)
    }
    
    /// Load all metadata from JSON file
    func loadMetadata() -> [EPUBMetadata] {
        do {
            let fileURL = try getMetadataFileURL()
            
            // If file doesn't exist, return empty array
            guard fileManager.fileExists(atPath: fileURL.path) else {
                // #region agent log
                let logPath = "/Users/calebcosta/coding/aud.io/.cursor/debug.log"
                if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"MetadataService.loadMetadata\",\"message\":\"Metadata file not found\",\"data\":{\"fileURL\":\"\(fileURL.path)\"},\"runId\":\"run1\",\"hypothesisId\":\"C\"}\n".data(using: .utf8),
                   let fileHandle = FileHandle(forWritingAtPath: logPath) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(logData)
                    fileHandle.closeFile()
                } else if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"MetadataService.loadMetadata\",\"message\":\"Metadata file not found\",\"data\":{\"fileURL\":\"\(fileURL.path)\"},\"runId\":\"run1\",\"hypothesisId\":\"C\"}\n".data(using: .utf8) {
                    try? logData.write(to: URL(fileURLWithPath: logPath), options: [])
                }
                // #endregion
                return []
            }
            
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let metadata = try decoder.decode([EPUBMetadata].self, from: data)
            
            // #region agent log
            let logPath = "/Users/calebcosta/coding/aud.io/.cursor/debug.log"
            let coversInfo = metadata.map { "\($0.id.uuidString):\($0.coverImagePath ?? "nil")" }.joined(separator: ",")
            if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"MetadataService.loadMetadata\",\"message\":\"Loaded metadata from JSON\",\"data\":{\"count\":\(metadata.count),\"covers\":\"\(coversInfo)\"},\"runId\":\"run1\",\"hypothesisId\":\"C\"}\n".data(using: .utf8),
               let fileHandle = FileHandle(forWritingAtPath: logPath) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(logData)
                fileHandle.closeFile()
            } else if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"MetadataService.loadMetadata\",\"message\":\"Loaded metadata from JSON\",\"data\":{\"count\":\(metadata.count),\"covers\":\"\(coversInfo)\"},\"runId\":\"run1\",\"hypothesisId\":\"C\"}\n".data(using: .utf8) {
                try? logData.write(to: URL(fileURLWithPath: logPath), options: [])
            }
            // #endregion
            
            return metadata
        } catch {
            // If decoding fails, return empty array (corrupted file)
            print("Error loading metadata: \(error.localizedDescription)")
            
            // #region agent log
            let logPath = "/Users/calebcosta/coding/aud.io/.cursor/debug.log"
            if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"MetadataService.loadMetadata\",\"message\":\"Error loading metadata\",\"data\":{\"error\":\"\(error.localizedDescription)\"},\"runId\":\"run1\",\"hypothesisId\":\"C\"}\n".data(using: .utf8),
               let fileHandle = FileHandle(forWritingAtPath: logPath) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(logData)
                fileHandle.closeFile()
            } else if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"MetadataService.loadMetadata\",\"message\":\"Error loading metadata\",\"data\":{\"error\":\"\(error.localizedDescription)\"},\"runId\":\"run1\",\"hypothesisId\":\"C\"}\n".data(using: .utf8) {
                try? logData.write(to: URL(fileURLWithPath: logPath), options: [])
            }
            // #endregion
            
            return []
        }
    }
    
    /// Save metadata array to JSON file
    func saveMetadata(_ metadata: [EPUBMetadata]) throws {
        let fileURL = try getMetadataFileURL()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(metadata)
            try data.write(to: fileURL, options: .atomic)
            
            // #region agent log
            let logPath = "/Users/calebcosta/coding/aud.io/.cursor/debug.log"
            let coversInfo = metadata.map { "\($0.id.uuidString):\($0.coverImagePath ?? "nil")" }.joined(separator: ",")
            if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"MetadataService.saveMetadata\",\"message\":\"Saved metadata\",\"data\":{\"count\":\(metadata.count),\"covers\":\"\(coversInfo)\"},\"runId\":\"run1\",\"hypothesisId\":\"C\"}\n".data(using: .utf8),
               let fileHandle = FileHandle(forWritingAtPath: logPath) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(logData)
                fileHandle.closeFile()
            } else if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"MetadataService.saveMetadata\",\"message\":\"Saved metadata\",\"data\":{\"count\":\(metadata.count),\"covers\":\"\(coversInfo)\"},\"runId\":\"run1\",\"hypothesisId\":\"C\"}\n".data(using: .utf8) {
                try? logData.write(to: URL(fileURLWithPath: logPath), options: [])
            }
            // #endregion
        } catch {
            throw MetadataServiceError.fileWriteFailed(error)
        }
    }
    
    /// Add new metadata entry
    func addMetadata(_ metadata: EPUBMetadata) throws {
        var allMetadata = loadMetadata()
        allMetadata.append(metadata)
        try saveMetadata(allMetadata)
    }
    
    /// Update existing metadata entry
    func updateMetadata(_ metadata: EPUBMetadata) throws {
        var allMetadata = loadMetadata()
        
        guard let index = allMetadata.firstIndex(where: { $0.id == metadata.id }) else {
            throw MetadataServiceError.metadataNotFound
        }
        
        allMetadata[index] = metadata
        try saveMetadata(allMetadata)
    }
    
    /// Delete metadata entry by ID
    func deleteMetadata(id: UUID) throws {
        var allMetadata = loadMetadata()
        allMetadata.removeAll { $0.id == id }
        try saveMetadata(allMetadata)
    }
    
    /// Get metadata by ID
    func getMetadata(id: UUID) -> EPUBMetadata? {
        let allMetadata = loadMetadata()
        return allMetadata.first { $0.id == id }
    }
    
    /// Migrate existing EPUB files to metadata system
    /// Scans EPUBs directory and creates metadata entries for files without metadata
    func migrateExistingEPUBs() throws {
        let fileManager = EPUBFileManager.shared
        let epubURLs = fileManager.getStoredEPUBs()
        var existingMetadata = loadMetadata()
        let existingFilePaths = Set(existingMetadata.map { $0.filePath })
        
        for epubURL in epubURLs {
            let filePath = epubURL.path
            
            // Skip if metadata already exists for this file
            if existingFilePaths.contains(filePath) {
                continue
            }
            
            // Create metadata entry with filename as title
            let filename = epubURL.lastPathComponent
            let title = (filename as NSString).deletingPathExtension
            let metadata = EPUBMetadata(
                title: title,
                filePath: filePath,
                importDate: Date()
            )
            
            existingMetadata.append(metadata)
        }
        
        try saveMetadata(existingMetadata)
    }
}
