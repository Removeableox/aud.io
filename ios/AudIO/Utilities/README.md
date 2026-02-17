# Utilities

This folder contains helper functions, extensions, and utility code used throughout the AudIO app.

## Purpose

Utilities provide:
- **Extensions** - Swift extensions for built-in types
- **Helper functions** - reusable utility functions
- **Formatters** - data formatting utilities
- **Validators** - input validation helpers
- **Constants** - app-wide constants and configuration

## Common Use Cases

### Swift Extensions
Extensions to add functionality to existing types:
```swift
extension String {
    func isValidEPUBFilename() -> Bool {
        // Validation logic
    }
}
```

### Formatters
Format data for display:
- Date formatters
- Number formatters
- Text formatters

### Validators
Validate user input or data:
- Email validation
- File type validation
- Input sanitization

### Constants
App-wide constants:
- Default values
- Configuration values
- Magic numbers/strings

## Guidelines

- Keep utilities **pure** - no side effects when possible
- Make utilities **generic** and reusable
- Use **extensions** to add functionality to existing types
- Group related utilities in the same file
- Document utility functions with clear names and comments

## File Organization

Group related utilities together:
- `String+Extensions.swift` - String extensions
- `Date+Extensions.swift` - Date extensions
- `URL+Extensions.swift` - URL extensions
- `Formatters.swift` - All formatters
- `Validators.swift` - All validators
- `Constants.swift` - App constants

## Examples

Future utilities that will be added here:
- `String+Extensions.swift` - String manipulation helpers
- `Date+Formatters.swift` - Date formatting utilities
- `Color+Extensions.swift` - Custom color definitions
- `View+Extensions.swift` - SwiftUI view modifiers
- `Constants.swift` - App-wide constants (defaults, limits, etc.)
