# Technologies used

## Languages
- **Swift 5**
- **XML plist** (Info.plist / entitlements)
- **YAML** (`project.yml` for XcodeGen)
- **Shell** (build/install/registration scripts)

## Apple frameworks
- **SwiftUI** (host app + widget UI)
- **WidgetKit** (widget timeline/provider/rendering)
- **AppIntents** (manual refresh intent + configuration intent)
- **Foundation** (networking, dates, persistence helpers)

## Build/project tooling
- **Xcode / xcodebuild**
- **Xcode project (`.xcodeproj`)**
- **XcodeGen** (template generation path)

## Platform/runtime services
- **PluginKit (`pluginkit`)** for extension registration
- **macOS Dock / NotificationCenter** for widget host UI lifecycle

## Data/API
- **OpenF1 REST API**
  - `meetings`
  - `sessions`
  - `session_result`
  - `drivers`

## Security/runtime configuration
- App Sandbox entitlements (app + widget)
- Network client entitlement (outbound HTTPS)
- Optional App Group/shared defaults usage
