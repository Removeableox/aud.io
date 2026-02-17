# Models

This folder contains data structures and business logic models for the AudIO app.

## Purpose

Models represent the core data structures used throughout the application. They should be:
- **Pure data structures** - contain properties and basic validation logic
- **Swift value types** when possible (structs, enums)
- **Codable** when they need to be persisted or serialized
- **Independent** of UI and presentation logic

## What Belongs Here

- EPUB metadata models (title, author, cover image, file path, import date)
- Reading progress models (book ID, chapter index, position/offset, last read date)
- Chapter and content models
- Sentence models for TTS
- Any other domain-specific data structures

## Examples

Future models that will be added here:
- `EPUBMetadata.swift` - Stores EPUB book metadata
- `ReadingProgress.swift` - Tracks reading position
- `Chapter.swift` - Represents a chapter in an EPUB
- `Sentence.swift` - Represents a sentence for TTS playback

## Guidelines

- Keep models simple and focused on data representation
- Avoid business logic in models (that belongs in Services or ViewModels)
- Use Swift's type system effectively (Optionals, Enums, etc.)
- Document complex models with comments
