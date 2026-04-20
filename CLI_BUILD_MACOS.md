# Build and install from CLI (macOS)

This guide builds and installs the app without opening Xcode UI.

## 1) Prerequisites
- macOS with Xcode installed
- Command line tools enabled (`xcode-select --install`)
- Valid signing team configured in project (already set in this repo template)

## 2) Build (Debug)
From `XcodeProjectTemplate`:

```bash
cd openf1-macos-widget/XcodeProjectTemplate

xcodebuild \
  -project OpenF1Dashboard.xcodeproj \
  -scheme OpenF1DashboardApp \
  -configuration Debug \
  -destination 'platform=macOS' \
  build
```

## 3) Locate built app

```bash
BUILT_APP=$(find "$HOME/Library/Developer/Xcode/DerivedData" \
  -type d -path '*/Build/Products/Debug/OpenF1Dashboard.app' | head -n 1)

echo "$BUILT_APP"
```

## 4) Install to ~/Applications

```bash
rm -rf "$HOME/Applications/OpenF1Dashboard.app"
cp -R "$BUILT_APP" "$HOME/Applications/OpenF1Dashboard.app"
xattr -dr com.apple.quarantine "$HOME/Applications/OpenF1Dashboard.app" 2>/dev/null || true
```

## 5) Register widget extension (clean)

```bash
# Remove stale registrations for this widget bundle id
pluginkit -m -A -D -v -p com.apple.widgetkit-extension \
  | grep -i 'com.afsilva.OpenF1DashboardApp.widget' \
  | awk '{print $NF}' \
  | while read -r p; do [ -n "$p" ] && pluginkit -r "$p" || true; done

# Register only installed app/appex
pluginkit -a "$HOME/Applications/OpenF1Dashboard.app"
pluginkit -a "$HOME/Applications/OpenF1Dashboard.app/Contents/PlugIns/OpenF1DashboardWidget.appex"
```

## 6) Refresh host services

```bash
killall NotificationCenter || true
killall Dock || true
killall Finder || true
```

## 7) Verify active registration

```bash
pluginkit -m -A -D -v -p com.apple.widgetkit-extension \
  | grep -i 'com.afsilva.OpenF1DashboardApp.widget'
```

Expected: one active entry pointing to:
`~/Applications/OpenF1Dashboard.app/Contents/PlugIns/OpenF1DashboardWidget.appex`

## 8) Launch app

```bash
open "$HOME/Applications/OpenF1Dashboard.app"
```

Then open **Edit Widgets** and add **OpenF1Dashboard**.

---

## Optional: Generate project with XcodeGen (if desired)

```bash
cd openf1-macos-widget/XcodeProjectTemplate
./Scripts/generate_xcodeproj.sh
```

(Use this only if you intentionally regenerate from `project.yml`.)
