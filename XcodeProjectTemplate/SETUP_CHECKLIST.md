# OpenF1 Dashboard — Ready-to-import Xcode Project Checklist

This folder is a near-ready Xcode template using **XcodeGen**.

## 1) Generate the Xcode project

```bash
cd openf1-macos-widget/XcodeProjectTemplate
./Scripts/generate_xcodeproj.sh
open OpenF1Dashboard.xcodeproj
```

---

## 2) Target-by-target file placement (already pre-structured)

### Target: `OpenF1DashboardApp` (macOS App)

Include:
- `OpenF1DashboardApp/OpenF1HostApp.swift`
- `OpenF1Shared/OpenF1Models.swift`
- `OpenF1Shared/OpenF1Service.swift`

Build settings/artifacts:
- Info.plist: `Config/OpenF1DashboardApp-Info.plist`
- Entitlements: `Config/OpenF1DashboardApp.entitlements`

### Target: `OpenF1DashboardWidget` (Widget Extension)

Include:
- `OpenF1DashboardWidget/OpenF1Widget.swift`
- `OpenF1DashboardWidget/RefreshNowIntent.swift`
- `OpenF1Shared/OpenF1Models.swift`
- `OpenF1Shared/OpenF1Service.swift`

Build settings/artifacts:
- Info.plist: `Config/OpenF1DashboardWidget-Info.plist`
- Entitlements: `Config/OpenF1DashboardWidget.entitlements`

---

## 3) Capabilities checklist (must-do)

In **Signing & Capabilities**, configure both targets:

### App target (`OpenF1DashboardApp`)
- [ ] Team selected
- [ ] Bundle identifier set (example: `com.yourorg.OpenF1DashboardApp`)
- [ ] **App Sandbox** enabled
- [ ] **App Groups** enabled
- [ ] App Group added (example: `group.com.yourorg.openf1widget`)

### Widget target (`OpenF1DashboardWidget`)
- [ ] Team selected
- [ ] Bundle identifier set (example: `com.yourorg.OpenF1DashboardApp.widget`)
- [ ] **App Sandbox** enabled
- [ ] **App Groups** enabled
- [ ] **Same App Group** added as app target

---

## 4) Replace app-group identifier in code

Edit:
- `OpenF1Shared/OpenF1Service.swift`

Replace:
- `group.com.example.openf1widget`

With your real group, e.g.:
- `group.com.yourorg.openf1widget`

---

## 5) Bundle IDs in `project.yml`

Update:
- `PRODUCT_BUNDLE_IDENTIFIER` for both targets in `project.yml`

Then re-run:

```bash
./Scripts/generate_xcodeproj.sh
```

---

## 6) Run and validate

- [ ] Build and run app target once
- [ ] Add widget from macOS widget gallery
- [ ] Trigger **Refresh OpenF1 Now** intent and confirm timeline reload
- [ ] Verify cache behavior (offline fallback still shows data)
- [ ] Validate logs in Xcode + Console.app (no sensitive payload output)

---

## 7) Optional hardening before distribution

- [ ] Add explicit privacy manifest if needed by your org policy
- [ ] Add structured logging with redaction rules
- [ ] Add unit tests for query validation, cache eviction, and standings aggregation
- [ ] Add CI checks (swiftlint/test/build)
