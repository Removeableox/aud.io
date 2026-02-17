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
                if viewModel.epubMetadata.isEmpty {
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
            .sheet(isPresented: $viewModel.showRenameSheet) {
                if let metadata = viewModel.selectedMetadata {
                    RenameBookSheet(
                        metadata: metadata,
                        isPresented: $viewModel.showRenameSheet,
                        onSave: { newTitle in
                            viewModel.renameBook(id: metadata.id, newTitle: newTitle)
                        }
                    )
                }
            }
            .sheet(isPresented: $viewModel.showImagePicker) {
                if let metadata = viewModel.selectedMetadata {
                    CoverImagePicker(isPresented: $viewModel.showImagePicker) { image in
                        viewModel.handleImageSelected(image)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCropView) {
                if let image = viewModel.imageToCrop {
                    CropImageView(
                        image: image,
                        isPresented: $viewModel.showCropView,
                        onCrop: { croppedImage in
                            viewModel.handleImageCropped(croppedImage)
                        }
                    )
                }
            }
            .alert("Delete Book", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    viewModel.metadataToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    viewModel.confirmDelete()
                }
            } message: {
                if let metadata = viewModel.metadataToDelete {
                    Text("Are you sure you want to delete '\(metadata.displayTitle)'? This action cannot be undone.")
                }
            }
            .alert("Error", isPresented: .constant(viewModel.importError != nil)) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                if let error = viewModel.importError {
                    Text(error)
                }
            }
            .alert("Success", isPresented: .constant(viewModel.importSuccessMessage != nil)) {
                Button("OK") {
                    viewModel.clearMessages()
                }
            } message: {
                if let message = viewModel.importSuccessMessage {
                    Text(message)
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
                .font(.system(size: 22, weight: .semibold))
            
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
                ForEach(viewModel.epubMetadata) { metadata in
                    NavigationLink(destination: ReaderView(metadata: metadata)) {
                        EPUBCard(metadata: metadata, viewModel: viewModel)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

// MARK: - EPUB Card

struct EPUBCard: View {
    let metadata: EPUBMetadata
    let viewModel: LibraryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cover image or placeholder
            coverImageView
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Title
            Text(metadata.displayTitle)
                .font(.system(size: 15, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Author or file size
            if let author = metadata.author, !author.isEmpty {
                Text(author)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Text(fileSizeString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: {
                viewModel.prepareRename(for: metadata)
            }) {
                Label("Rename", systemImage: "pencil")
            }
            
            Button(action: {
                viewModel.prepareAddCover(for: metadata)
            }) {
                Label("Change Cover", systemImage: "photo")
            }
            
            Divider()
            
            Button(role: .destructive, action: {
                viewModel.prepareDelete(for: metadata)
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Cover Image View
    
    private var coverImageView: some View {
        Group {
            if let coverURL = metadata.coverImageURL,
               let imageData = try? Data(contentsOf: coverURL),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)
                    .clipped()
                    .cornerRadius(8)
                    .onAppear {
                        // #region agent log
                        let logPath = "/Users/calebcosta/coding/aud.io/.cursor/debug.log"
                        let coverPath = metadata.coverImagePath ?? "nil"
                        let fileExists = FileManager.default.fileExists(atPath: coverURL.path)
                        if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryView.coverImageView\",\"message\":\"Rendering cover\",\"data\":{\"bookId\":\"\(metadata.id.uuidString)\",\"coverImagePath\":\"\(coverPath)\",\"coverURL\":\"\(coverURL.path)\",\"fileExists\":\(fileExists)},\"runId\":\"run1\",\"hypothesisId\":\"D\"}\n".data(using: .utf8),
                           let fileHandle = FileHandle(forWritingAtPath: logPath) {
                            fileHandle.seekToEndOfFile()
                            fileHandle.write(logData)
                            fileHandle.closeFile()
                        } else if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryView.coverImageView\",\"message\":\"Rendering cover\",\"data\":{\"bookId\":\"\(metadata.id.uuidString)\",\"coverImagePath\":\"\(coverPath)\",\"coverURL\":\"\(coverURL.path)\",\"fileExists\":\(fileExists)},\"runId\":\"run1\",\"hypothesisId\":\"D\"}\n".data(using: .utf8) {
                            try? logData.write(to: URL(fileURLWithPath: logPath), options: [])
                        }
                        // #endregion
                    }
            } else {
                // Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor.opacity(0.1))
                        .aspectRatio(2/3, contentMode: .fit)
                    
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.accentColor)
                }
                .onAppear {
                    // #region agent log
                    let logPath = "/Users/calebcosta/coding/aud.io/.cursor/debug.log"
                    let coverPath = metadata.coverImagePath ?? "nil"
                    let coverURL = metadata.coverImageURL
                    let fileExists = coverURL != nil ? FileManager.default.fileExists(atPath: coverURL!.path) : false
                    if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryView.coverImageView\",\"message\":\"Showing placeholder\",\"data\":{\"bookId\":\"\(metadata.id.uuidString)\",\"coverPath\":\"\(coverPath)\",\"hasCoverURL\":\(coverURL != nil),\"fileExists\":\(fileExists)},\"runId\":\"run1\",\"hypothesisId\":\"D\"}\n".data(using: .utf8),
                       let fileHandle = FileHandle(forWritingAtPath: logPath) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(logData)
                        fileHandle.closeFile()
                    } else if let logData = "{\"id\":\"log_\(UUID().uuidString)\",\"timestamp\":\(Int(Date().timeIntervalSince1970 * 1000)),\"location\":\"LibraryView.coverImageView\",\"message\":\"Showing placeholder\",\"data\":{\"bookId\":\"\(metadata.id.uuidString)\",\"coverPath\":\"\(coverPath)\",\"hasCoverURL\":\(coverURL != nil),\"fileExists\":\(fileExists)},\"runId\":\"run1\",\"hypothesisId\":\"D\"}\n".data(using: .utf8) {
                        try? logData.write(to: URL(fileURLWithPath: logPath), options: [])
                    }
                    // #endregion
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var fileSizeString: String {
        let fileURL = URL(fileURLWithPath: metadata.filePath)
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let fileSize = attributes[.size] as? Int64 else {
            return ""
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}

// MARK: - Rename Book Sheet

struct RenameBookSheet: View {
    let metadata: EPUBMetadata
    @Binding var isPresented: Bool
    let onSave: (String) -> Void
    
    @State private var newTitle: String
    @FocusState private var isTextFieldFocused: Bool
    
    init(metadata: EPUBMetadata, isPresented: Binding<Bool>, onSave: @escaping (String) -> Void) {
        self.metadata = metadata
        self._isPresented = isPresented
        self.onSave = onSave
        _newTitle = State(initialValue: metadata.displayTitle)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Book Title", text: $newTitle)
                        .focused($isTextFieldFocused)
                } header: {
                    Text("Rename Book")
                } footer: {
                    Text("Enter a custom title for this book. Leave empty to use the original title.")
                }
            }
            .navigationTitle("Rename Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(newTitle)
                        isPresented = false
                    }
                    .font(.system(size: 17, weight: .semibold))
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LibraryView(viewModel: LibraryViewModel())
}
