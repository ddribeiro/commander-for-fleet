# AGENTS.md

## Project Structure
- Single iOS app project (Swift/SwiftUI)
- No subpackages detected

## Development Workflow
1. **Build**: `xcodebuild` (default Xcode project)
2. **Test**: Use Xcode simulator or connected devices
3. **Authentication**: Requires Fleet API token (see README for details)
4. **Distribution**: TestFlight (join via [link](https://testflight.apple.com/join/VH22aGlx))

## Key Commands
- `xcodebuild` - Build project
- `open Cygnet.xcodeproj` - Open Xcode project
- `swift run` - Run via Swift CLI (if configured)

## Authentication Setup
1. Get API token from Fleet UI
2. Use Universal Clipboard to transfer token to iOS device
3. Enable "API Token" mode in app settings