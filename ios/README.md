# AudIO iOS Project

This is the iOS application for AudIO - an iPhone app for reading EPUBs aloud.

## Project Structure

```
ios/
├── AudIO.xcodeproj/          # Xcode project file
├── AudIO/                    # Main app source code
│   ├── Views/                # SwiftUI views
│   │   ├── README.md         # Views documentation
│   │   ├── ContentView.swift
│   │   └── DocumentPickerView.swift
│   ├── Models/               # Data models
│   │   ├── README.md         # Models documentation
│   │   └── .gitkeep          # Ensures folder is tracked in git
│   ├── ViewModels/           # View models (MVVM pattern)
│   │   ├── README.md         # ViewModels documentation
│   │   └── LibraryViewModel.swift
│   ├── Services/             # Business logic services
│   │   ├── README.md         # Services documentation
│   │   └── EPUBFileManager.swift
│   ├── Utilities/            # Utility functions and helpers
│   │   ├── README.md         # Utilities documentation
│   │   └── .gitkeep          # Ensures folder is tracked in git
│   ├── Assets.xcassets/      # App icons and assets
│   ├── AudIOApp.swift        # App entry point
│   └── Info.plist            # App configuration
└── project.yml               # XcodeGen configuration (optional)
```

### Folder Documentation

Each folder contains a `README.md` file that explains:
- The purpose of the folder
- What types of files belong there
- Guidelines for organizing code
- Examples of current and future files

This documentation helps maintain consistency and makes it easier for developers to understand where to place new code.

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
- **Models**: Data structures and business logic (see `Models/README.md`)
- **Views**: SwiftUI views for UI presentation (see `Views/README.md`)
- **ViewModels**: Business logic and state management for views (see `ViewModels/README.md`)
- **Services**: Reusable services for EPUB parsing, TTS, file management, etc. (see `Services/README.md`)
- **Utilities**: Helper functions and extensions (see `Utilities/README.md`)

Each folder contains detailed documentation explaining its purpose, guidelines, and examples. Refer to the README files in each folder for more information about organizing code.

## Next Steps

See `mvp_tickets.csv` in the root directory for the full list of features to implement.
