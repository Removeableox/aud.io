//
//  Chapter.swift
//  AudIO
//
//  Created on Feb 17, 2026.
//

import Foundation

struct Chapter: Identifiable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let index: Int
    let bookId: UUID
    
    init(id: UUID = UUID(), title: String, content: String, index: Int, bookId: UUID) {
        self.id = id
        self.title = title
        self.content = content
        self.index = index
        self.bookId = bookId
    }
}
