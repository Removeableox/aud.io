# AudIO iOS Project

This is the iOS application for AudIO - an iPhone app for reading EPUBs aloud.

## Project Structure

```
ios/
├── AudIO.xcodeproj/          # Xcode project file
├── AudIO/                    # Main app source code
│   ├── Views/                # SwiftUI views
│   ├── Models/               # Data models
│   ├── ViewModels/           # View models (MVVM pattern)
│   ├── Services/             # Business logic services
│   ├── Utilities/            # Utility functions and helpers
│   ├── Assets.xcassets/      # App icons and assets
│   ├── AudIOApp.swift        # App entry point
│   └── Info.plist            # App configuration
└── project.yml               # XcodeGen configuration (optional)
```

## Requirements

- Xcode 15.0 or later
- iOS 15.0+ deployment target
- Swift 5.0+

## Setup

1. Open `AudIO.xcodeproj` in Xcode
2. Select your development team in the project settings (Signing & Capabilities)
3. Build and run the project (⌘R)

## Bundle ID

The app bundle identifier is: `com.audio.AudIO`

## Architecture

The project follows the MVVM (Model-View-ViewModel) architecture pattern:
- **Models**: Data structures and business logic
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: Business logic and state management for views
- **Services**: Reusable services for EPUB parsing, TTS, file management, etc.
- **Utilities**: Helper functions and extensions

## Next Steps

See `mvp_tickets.csv` in the root directory for the full list of features to implement.
