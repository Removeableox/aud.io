# Services

This folder contains reusable business logic services for the AudIO app.

## Purpose

Services encapsulate reusable functionality that can be used across multiple ViewModels or parts of the app:
- **Business logic** - complex operations and algorithms
- **External integrations** - file system, network, third-party APIs
- **Data persistence** - saving and retrieving data
- **Reusable operations** - functionality used by multiple ViewModels

## Current Services

- `EPUBFileManager.swift` - Handles EPUB file storage, retrieval, and file system operations

## Design Patterns

### Singleton Pattern
Many services use the singleton pattern for shared access:
```swift
class MyService {
    static let shared = MyService()
    private init() {}
}
```

### Dependency Injection
Services can be injected into ViewModels for better testability:
```swift
class MyViewModel {
    private let service: MyService
    
    init(service: MyService = MyService.shared) {
        self.service = service
    }
}
```

## Guidelines

- Services should be **stateless** or have minimal state
- Services should be **testable** - avoid tight coupling
- Services should handle **errors** and return Result types or throw errors
- Services should be **reusable** - not tied to specific views
- Document service APIs with clear method names and documentation

## Service Responsibilities

### File Management
- File storage and retrieval
- Directory management
- File operations (copy, move, delete)

### EPUB Processing
- EPUB parsing and extraction
- Chapter and content extraction
- Metadata extraction

### Text-to-Speech
- Audio generation
- Playback management
- Queue management

### Data Persistence
- UserDefaults storage
- Core Data operations (if needed)
- File-based storage

## Future Services

Services that will be added here:
- `EPUBParserService.swift` - Parses EPUB files and extracts content
- `TTSService.swift` - Handles text-to-speech synthesis
- `ProgressService.swift` - Manages reading progress persistence
- `MetadataService.swift` - Extracts and manages EPUB metadata
