# OpenF1 Dashboard — iOS-first Setup Checklist

This template is now intentionally **iOS-only active**.

## 1) Generate project

```bash
cd openf1-macos-widget/XcodeProjectTemplate
./Scripts/generate_xcodeproj.sh
open OpenF1Dashboard.xcodeproj
```

---

## 2) Active targets only

### `OpenF1DashboardiOSApp` (host app)
Includes:
- `OpenF1DashboardiOSApp/OpenF1iOSHostApp.swift`
- `OpenF1Shared/OpenF1Models.swift`
- `OpenF1Shared/OpenF1Service.swift`

### `OpenF1DashboardiOSWidget` (widget extension)
Includes:
- `OpenF1DashboardiOSWidget/OpenF1iOSWidget.swift`
- `OpenF1DashboardiOSWidget/RefreshNowIntent.swift`
- `OpenF1Shared/OpenF1Models.swift`
- `OpenF1Shared/OpenF1Service.swift`

---

## 3) Signing + capabilities

Configure Team and Bundle IDs for both iOS targets.

Enable **App Groups** on both:
- `OpenF1DashboardiOSApp`
- `OpenF1DashboardiOSWidget`

Use same group, e.g.:
- `group.com.yourorg.openf1widget`

---

## 4) Update App Group in code

Edit:
- `OpenF1Shared/OpenF1Service.swift`

Replace:
- `group.com.afsilva.openf1widget`

With your group.

---

## 5) Run + validate

- [ ] Build/run `OpenF1DashboardiOSApp` on iPhone/iPad (or simulator)
- [ ] Add widget from Home Screen widget gallery
- [ ] Test manual refresh button
- [ ] Verify offline/cache fallback behavior
- [ ] Verify medium and large layouts

---

## 6) macOS usage model

Use iPhone widgets on Mac for macOS surface.

Native macOS widget targets are deprecated/obsolete for this repo strategy.
