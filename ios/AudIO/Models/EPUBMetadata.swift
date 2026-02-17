//
//  EPUBMetadata.swift
//  AudIO
//
//  Created on Feb 17, 2026.
//

import Foundation

struct EPUBMetadata: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var author: String?
    var customTitle: String?
    let filePath: String
    var coverImagePath: String?
    let importDate: Date
    
    init(id: UUID = UUID(), title: String, author: String? = nil, customTitle: String? = nil, filePath: String, coverImagePath: String? = nil, importDate: Date = Date()) {
        self.id = id
        self.title = title
        self.author = author
        self.customTitle = customTitle
        self.filePath = filePath
        self.coverImagePath = coverImagePath
        self.importDate = importDate
    }
    
    /// Display title: customTitle if set, otherwise title, otherwise filename
    var displayTitle: String {
        if let customTitle = customTitle, !customTitle.isEmpty {
            return customTitle
        }
        if !title.isEmpty {
            return title
        }
        // Fallback to filename
        let url = URL(fileURLWithPath: filePath)
        return (url.lastPathComponent as NSString).deletingPathExtension
    }
    
    /// URL for the EPUB file
    var fileURL: URL {
        URL(fileURLWithPath: filePath)
    }
    
    /// URL for the cover image if available
    var coverImageURL: URL? {
        guard let coverImagePath = coverImagePath else { return nil }
        return URL(fileURLWithPath: coverImagePath)
    }
    
    /// Filename without extension
    var filename: String {
        let url = URL(fileURLWithPath: filePath)
        return (url.lastPathComponent as NSString).deletingPathExtension
    }
}
