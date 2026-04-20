# OpenF1 Dashboard — Unified Apple (macOS + iOS) Xcode Project Checklist

This folder is a near-ready Xcode template using **XcodeGen**.

## 1) Generate the Xcode project

```bash
cd openf1-macos-widget/XcodeProjectTemplate
./Scripts/generate_xcodeproj.sh
open OpenF1Dashboard.xcodeproj
```

---

## 2) Target-by-target file placement (already pre-structured)

### macOS targets

#### Target: `OpenF1DashboardApp` (macOS App)

Includes:
- `OpenF1DashboardApp/OpenF1HostApp.swift`
- `OpenF1Shared/OpenF1Models.swift`
- `OpenF1Shared/OpenF1Service.swift`

Build settings/artifacts:
- Info.plist: `Config/OpenF1DashboardApp-Info.plist`
- Entitlements: `Config/OpenF1DashboardApp.entitlements`

#### Target: `OpenF1DashboardWidget` (macOS Widget Extension)

Includes:
- `OpenF1DashboardWidget/OpenF1Widget.swift`
- `OpenF1DashboardWidget/RefreshNowIntent.swift`
- `OpenF1Shared/OpenF1Models.swift`
- `OpenF1Shared/OpenF1Service.swift`

Build settings/artifacts:
- Info.plist: `Config/OpenF1DashboardWidget-Info.plist`
- Entitlements: `Config/OpenF1DashboardWidget.entitlements`

### iOS targets

#### Target: `OpenF1DashboardiOSApp` (iOS App)

Includes:
- `OpenF1DashboardiOSApp/OpenF1iOSHostApp.swift`
- `OpenF1Shared/OpenF1Models.swift`
- `OpenF1Shared/OpenF1Service.swift`

Build settings/artifacts:
- Info.plist: `Config/OpenF1DashboardiOSApp-Info.plist`
- Entitlements: `Config/OpenF1DashboardiOSApp.entitlements`

#### Target: `OpenF1DashboardiOSWidget` (iOS Widget Extension)

Includes:
- `OpenF1DashboardiOSWidget/OpenF1iOSWidget.swift`
- `OpenF1DashboardiOSWidget/RefreshNowIntent.swift`
- `OpenF1Shared/OpenF1Models.swift`
- `OpenF1Shared/OpenF1Service.swift`

Build settings/artifacts:
- Info.plist: `Config/OpenF1DashboardiOSWidget-Info.plist`
- Entitlements: `Config/OpenF1DashboardiOSWidget.entitlements`

---

## 3) Capabilities checklist (must-do)

In **Signing & Capabilities**, configure all four targets with your Team and bundle IDs.

### App Group (shared cache/refresh flag between app + widget)

Enable **App Groups** for:
- `OpenF1DashboardApp`
- `OpenF1DashboardWidget`
- `OpenF1DashboardiOSApp`
- `OpenF1DashboardiOSWidget`

Add the same group to all (example):
- `group.com.yourorg.openf1widget`

### macOS sandbox/network

For macOS app + widget, keep:
- App Sandbox enabled
- Outbound network client allowed

---

## 4) Replace app-group identifier in code

Edit:
- `OpenF1Shared/OpenF1Service.swift`

Replace:
- `group.com.afsilva.openf1widget`

With your real group, e.g.:
- `group.com.yourorg.openf1widget`

---

## 5) Bundle IDs in `project.yml`

Update `PRODUCT_BUNDLE_IDENTIFIER` for all targets:
- `OpenF1DashboardApp`
- `OpenF1DashboardWidget`
- `OpenF1DashboardiOSApp`
- `OpenF1DashboardiOSWidget`

Then re-run:

```bash
./Scripts/generate_xcodeproj.sh
```

---

## 6) Run and validate

### macOS
- [ ] Build/run `OpenF1DashboardApp`
- [ ] Add macOS widget from widget gallery
- [ ] Trigger **Refresh OpenF1 Now** and confirm timeline reload

### iOS
- [ ] Build/run `OpenF1DashboardiOSApp` on device/simulator
- [ ] Add iOS widget from Home Screen widget gallery
- [ ] Trigger refresh and verify update timing/cache fallback

### Shared behavior checks
- [ ] Verify cache behavior (offline fallback still shows data)
- [ ] Verify adaptive refresh policy (daily off-weekend, hourly race weekend)
- [ ] Validate logs (no sensitive payload output)

---

## 7) Optional hardening before distribution

- [ ] Add unit tests for query validation, cache eviction, and standings aggregation
- [ ] Add snapshot tests for widget readability (especially iOS systemLarge)
- [ ] Add CI checks (swiftlint/test/build)
- [ ] Add release automation and signing profiles for both platforms
