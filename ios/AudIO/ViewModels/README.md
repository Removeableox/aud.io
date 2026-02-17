# ViewModels

This folder contains ViewModels that manage state and business logic for views, following the MVVM architecture pattern.

## Purpose

ViewModels serve as the bridge between Views and Models/Services:
- **State management** - manage view state using `@Published` properties
- **Business logic** - coordinate between Services and Models
- **Data transformation** - prepare data for display in Views
- **User action handling** - process user interactions from Views

## MVVM Pattern

The MVVM (Model-View-ViewModel) pattern separates concerns:
- **Models**: Data structures
- **Views**: UI presentation (SwiftUI views)
- **ViewModels**: Business logic and state management

```
View <--observes--> ViewModel <--uses--> Services/Models
```

## Current ViewModels

- `LibraryViewModel.swift` - Manages EPUB library state, import operations, and stored EPUBs list

## Key Concepts

### @MainActor
ViewModels are marked with `@MainActor` to ensure all updates happen on the main thread, which is required for SwiftUI updates.

### ObservableObject
ViewModels conform to `ObservableObject` and use `@Published` properties to notify views of changes.

### Example Structure

```swift
@MainActor
class MyViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service: MyService
    
    init() {
        // Initialize
    }
    
    func loadData() {
        // Business logic
    }
}
```

## Guidelines

- ViewModels should be testable (use dependency injection for Services)
- Keep ViewModels focused on a single view or feature
- Use `@Published` for properties that Views need to observe
- Handle errors gracefully and provide user-friendly error messages
- Keep ViewModels independent of specific View implementations

## Future ViewModels

ViewModels that will be added here:
- `ReaderViewModel.swift` - Manages reader state, chapter navigation, progress
- `SettingsViewModel.swift` - Manages app settings and preferences
- `TTSViewModel.swift` - Manages text-to-speech playback state
