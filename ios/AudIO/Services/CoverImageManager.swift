//
//  CoverImageManager.swift
//  AudIO
//
//  Created on Feb 17, 2026.
//

import Foundation
import UIKit

enum CoverImageManagerError: LocalizedError {
    case documentsDirectoryNotFound
    case directoryCreationFailed
    case imageSaveFailed(Error)
    case imageNotFound
    case invalidImage
    
    var errorDescription: String? {
        switch self {
        case .documentsDirectoryNotFound:
            return "Documents directory not found"
        case .directoryCreationFailed:
            return "Failed to create Covers directory"
        case .imageSaveFailed(let error):
            return "Failed to save cover image: \(error.localizedDescription)"
        case .imageNotFound:
            return "Cover image not found"
        case .invalidImage:
            return "Invalid image data"
        }
    }
}

class CoverImageManager {
    static let shared = CoverImageManager()
    
    private let fileManager = FileManager.default
    private let coversDirectoryName = "Covers"
    
    private init() {}
    
    /// Get the Covers directory URL, creating it if it doesn't exist
    private func getCoversDirectory() throws -> URL {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CoverImageManagerError.documentsDirectoryNotFound
        }
        
        let coversDirectory = documentsDirectory.appendingPathComponent(coversDirectoryName, isDirectory: true)
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: coversDirectory.path) {
            do {
                try fileManager.createDirectory(at: coversDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw CoverImageManagerError.directoryCreationFailed
            }
        }
        
        return coversDirectory
    }
    
    /// Save cover image for a book
    /// - Parameters:
    ///   - image: The UIImage to save
    ///   - forBookId: The UUID of the book
    /// - Returns: Result containing the saved file URL on success, or an error on failure
    func saveCover(image: UIImage, forBookId: UUID) -> Result<URL, Error> {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return .failure(CoverImageManagerError.invalidImage)
        }
        
        do {
            let coversDirectory = try getCoversDirectory()
            let filename = "\(forBookId.uuidString).jpg"
            let fileURL = coversDirectory.appendingPathComponent(filename)
            
            try imageData.write(to: fileURL, options: .atomic)
            return .success(fileURL)
        } catch {
            if let coverError = error as? CoverImageManagerError {
                return .failure(coverError)
            }
            return .failure(CoverImageManagerError.imageSaveFailed(error))
        }
    }
    
    /// Get cover image URL for a book
    /// - Parameter forBookId: The UUID of the book
    /// - Returns: URL of the cover image if it exists, nil otherwise
    func getCoverURL(forBookId: UUID) -> URL? {
        guard let coversDirectory = try? getCoversDirectory() else {
            return nil
        }
        
        let filename = "\(forBookId.uuidString).jpg"
        let fileURL = coversDirectory.appendingPathComponent(filename)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        
        return nil
    }
    
    /// Delete cover image for a book
    /// - Parameter forBookId: The UUID of the book
    func deleteCover(forBookId: UUID) {
        guard let coversDirectory = try? getCoversDirectory() else {
            return
        }
        
        let filename = "\(forBookId.uuidString).jpg"
        let fileURL = coversDirectory.appendingPathComponent(filename)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try? fileManager.removeItem(at: fileURL)
        }
    }
    
    /// Check if cover exists for a book
    /// - Parameter forBookId: The UUID of the book
    /// - Returns: True if cover exists, false otherwise
    func coverExists(forBookId: UUID) -> Bool {
        return getCoverURL(forBookId: forBookId) != nil
    }
}
