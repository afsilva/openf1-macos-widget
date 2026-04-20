# OpenF1 Dashboard (iOS Widget First: iOS + iPadOS + macOS via iPhone widgets)

This project is now intentionally simplified to a **single active widget path**:

- **Active/maintained:** iOS WidgetKit app + widget extension
- **Runs on:** iPhone, iPad, and macOS (via iPhone widgets on Mac)
- **Obsolete/deprecated:** native macOS widget target path

Data source: [OpenF1 API](https://api.openf1.org)

License: **GPL-3.0-or-later** (`LICENSE`)

---

## Why this simplification

You identified that the iOS widget path is more reliable in practice. To reduce complexity and maintenance burden, this repo now focuses on the widget path that works best across your devices.

That means:
- one primary app/widget target pair,
- one shared service/model path,
- fewer signing, cache, and extension-registration permutations.

---

## Compatibility

- **iOS 17+**
- **iPadOS 17+**
- **macOS (Apple Silicon) via iPhone widgets on Mac**

> Native macOS widget targets are kept in repo history/runtime folders for reference but are no longer generated as active targets from `project.yml`.

---

## Active project layout

```text
openf1-macos-widget/
  OpenF1Shared/
    OpenF1Models.swift
    OpenF1Service.swift

  # Active runtime sources
  OpenF1iOSHostApp/
    OpenF1iOSHostApp.swift
  OpenF1iOSWidget/
    OpenF1iOSWidget.swift
    RefreshNowIntent.swift

  XcodeProjectTemplate/
    project.yml                      # iOS-only active targets
    SETUP_CHECKLIST.md
    Scripts/generate_xcodeproj.sh
    Config/*.plist + *.entitlements
    OpenF1DashboardiOSApp/*          # active
    OpenF1DashboardiOSWidget/*       # active
    OpenF1Shared/*

  # Obsolete native macOS runtime paths (deprecated)
  OpenF1HostApp/
  OpenF1Widget/
  XcodeProjectTemplate/OpenF1DashboardApp/
  XcodeProjectTemplate/OpenF1DashboardWidget/
```

---

## Setup (iOS-first)

```bash
cd openf1-macos-widget/XcodeProjectTemplate
./Scripts/generate_xcodeproj.sh
open OpenF1Dashboard.xcodeproj
```

Then configure only:
- `OpenF1DashboardiOSApp`
- `OpenF1DashboardiOSWidget`

### Required capabilities

Enable the same **App Group** on both iOS targets, e.g.:
- `group.com.yourorg.openf1widget`

Update in code:
- `OpenF1Shared/OpenF1Service.swift`
- `AppGroupConfig.identifier`

---

## Behavior

- Calendar of next relevant sessions (non-canceled)
- Driver + constructor standings from OpenF1 session results
- Cache-first refresh with fallback to last-known-good model
- Manual refresh via widget intent button

Refresh policy:
- daily off-weekend
- hourly around race weekends

---

## Security posture (OWASP-aligned)

Key controls retained:
- fixed HTTPS host (`api.openf1.org`)
- endpoint allowlist
- query validation
- bounded response/cache sizes
- sanitized rendered text
- genericized error/fallback UI
- no secret/token handling in code/cache

See `SECURITY_OWASP_TOP10.md` for assessment details.

---

## Obsolete native macOS widget path

The following are now considered **obsolete/deprecated**:
- native macOS app/widget targets in generated project
- native macOS widget as primary distribution path

Reason: iOS widget path is the most reliable and already spans iOS/iPadOS/macOS usage pattern desired.

---

## Related docs

- `PROMPT.md` — updated regeneration prompts
- `SECURITY_OWASP_TOP10.md` — OWASP Top 10 assessment
- `APP_STORE_DEPLOYMENT.md` — deployment guidance
- `XcodeProjectTemplate/SETUP_CHECKLIST.md` — iOS-first setup checklist
