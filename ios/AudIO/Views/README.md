# Views

This folder contains SwiftUI views for UI presentation in the AudIO app.

## Purpose

Views are responsible for:
- **UI presentation** - displaying data to the user
- **User interaction** - handling taps, gestures, and input
- **Visual layout** - arranging UI elements
- **Delegating logic** - passing user actions to ViewModels

Views should be **simple and declarative**, with minimal business logic.

## Current Views

- `ContentView.swift` - Main welcome screen with EPUB import functionality
- `DocumentPickerView.swift` - SwiftUI wrapper for UIDocumentPickerViewController

## MVVM Pattern

Views follow the MVVM (Model-View-ViewModel) pattern:
- Views observe ViewModels using `@StateObject` or `@ObservedObject`
- Views call ViewModel methods in response to user actions
- Views display data from ViewModel's `@Published` properties
- Views do NOT contain business logic or data manipulation

## Guidelines

- Keep views focused on presentation
- Extract reusable UI components into separate view files
- Use SwiftUI modifiers for styling and layout
- Handle navigation and sheet presentation through ViewModels
- Keep views testable by minimizing dependencies

## Future Views

Views that will be added here:
- `LibraryView.swift` - Main library screen showing all EPUBs
- `ReaderView.swift` - EPUB reader view with text display
- `SettingsView.swift` - App settings screen
- `ChapterListView.swift` - Chapter navigation view
