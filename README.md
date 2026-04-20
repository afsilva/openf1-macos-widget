# OpenF1 Dashboard (Unified Apple: macOS + iOS Widgets)

A WidgetKit-based Apple-platform widget project that follows the same product and reliability principles as `openf1-gnome-extension`:

1. **Calendar**
   - Upcoming **non-canceled** race weekend
   - During active weekend, highlights the **next upcoming session/event**
   - Compact display of race/session timing

2. **Championship points**
   - Driver standings (aggregated from OpenF1 race/sprint session results)
   - Constructor standings (team point aggregation)

3. **Reliability / API hygiene**
   - Cache-first endpoint retrieval
   - Refresh policy:
     - **once/day** during non-race periods
     - **once/hour** during race weekends (or close to next weekend)
   - Manual refresh support via `Refresh Now` App Intent

Data source: [OpenF1 API](https://api.openf1.org)

License: **GPL-3.0-or-later** (`LICENSE`)

---

## Compatibility

- **macOS 26.4+** (WidgetKit target)
- **iOS 17+** (WidgetKit target)
- SwiftUI + WidgetKit + AppIntents

> The repo is organized for a unified Apple approach: shared logic + platform-specific app/widget targets.

---

## Project layout

```text
openf1-macos-widget/
  OpenF1Shared/
    OpenF1Models.swift
    OpenF1Service.swift

  # macOS runtime sources
  OpenF1HostApp/
    OpenF1HostApp.swift
  OpenF1Widget/
    OpenF1Widget.swift
    RefreshNowIntent.swift

  # iOS runtime sources
  OpenF1iOSHostApp/
    OpenF1iOSHostApp.swift
  OpenF1iOSWidget/
    OpenF1iOSWidget.swift
    RefreshNowIntent.swift

  XcodeProjectTemplate/
    project.yml
    SETUP_CHECKLIST.md
    Scripts/generate_xcodeproj.sh
    Config/*.plist + *.entitlements
    OpenF1DashboardApp/*          # macOS host app
    OpenF1DashboardWidget/*       # macOS widget
    OpenF1DashboardiOSApp/*       # iOS host app
    OpenF1DashboardiOSWidget/*    # iOS widget
    OpenF1Shared/*
```

If you want the fastest setup path, use `XcodeProjectTemplate/` directly.

---

## Setup in Xcode (unified)

### Option A (recommended): Ready-to-import template

```bash
cd openf1-macos-widget/XcodeProjectTemplate
./Scripts/generate_xcodeproj.sh
open OpenF1Dashboard.xcodeproj
```

Then follow:
- `openf1-macos-widget/XcodeProjectTemplate/SETUP_CHECKLIST.md`

### Option B: Manual integration

1. Create Apple app targets + widget extension targets for macOS and iOS.
2. Add an **App Group** capability to all app/widget targets (same group across all four).
3. Copy files from this folder into your project:
   - `OpenF1Shared/*` into a shared group included in all targets
   - `OpenF1Widget/*` + `OpenF1HostApp/*` for macOS targets
   - `OpenF1iOSWidget/*` + `OpenF1iOSHostApp/*` for iOS targets
4. In `OpenF1Service.swift`, replace `AppGroupConfig.identifier` with your real App Group identifier.
5. Build/run host apps, then add widgets from the corresponding widget galleries.

---

## Shared architecture (industry-standard Apple pattern)

- **Shared core module** (`OpenF1Shared`)
  - Models, OpenF1 networking, cache envelope, standings aggregation, refresh policy
- **Platform-specific UI targets**
  - macOS app + widget
  - iOS app + widget
- **Single App Group-backed cache**
  - Enables shared widget/app refresh flags and persistent endpoint cache per platform app suite

This keeps behavior aligned while allowing per-platform UI tuning.

---

## Security review (OWASP Top 10 aligned)

This project is a local Apple UI client with outbound HTTPS requests to OpenF1. It does not process credentials, auth tokens, payments, or arbitrary user-provided query input. The implementation applies OWASP-aligned controls:

### A01 Broken Access Control
- No privileged backend actions or role/authorization model in scope.
- Widget only reads public API data and writes cache in app-group container.

### A02 Cryptographic Failures
- Uses HTTPS OpenF1 endpoint only (`https://api.openf1.org/v1`).
- No secrets stored in source or cache.

### A03 Injection
- API path/query is allowlisted (`meetings`, `sessions`, `session_result`, `drivers`).
- Query string is validated against URL-safe characters.
- UI output is sanitized to strip control characters and normalize whitespace.

### A04 Insecure Design
- Cache-first design reduces API pressure and failure exposure.
- Explicit refresh policy (daily off-weekend, hourly race weekend).
- Defensive handling for network/API failures with generic fallback UI.

### A05 Security Misconfiguration
- HTTP requests use explicit timeout.
- Error surface in widget is generic (no raw payload dump).
- App Group scope is explicit and must be configured by developer.

### A06 Vulnerable and Outdated Components
- Keep macOS/iOS/Xcode/SDK dependencies updated.
- No bundled third-party runtime packages in this source pack.

### A07 Identification and Authentication Failures
- Not applicable (no authentication workflow).

### A08 Software and Data Integrity Failures
- API payloads are decoded into typed models.
- Response size is bounded (1MB cap).
- On-disk cache size and endpoint entry count are bounded.

### A09 Security Logging and Monitoring Failures
- Failures degrade safely in-widget (generic status/fallback rows).
- Operational diagnostics should be monitored via Xcode console / unified logs during development and release testing.

### A10 Server-Side Request Forgery (SSRF)
- Endpoint host is fixed constant (`api.openf1.org`).
- Dynamic path/query is endpoint-allowlisted and validated.

## Additional hardening implemented
- Response size cap (1MB)
- On-disk cache size cap (2MB)
- Endpoint cache entry cap
- Sanitized UI text rendering
- Genericized error surface in widget

---

## Design parity with GNOME extension

This project preserves the same core behavior:

- Skip fully canceled weekends
- Show next meaningful event/session
- Compute standings from OpenF1 `session_result`
- Enrich driver/team from `drivers` endpoint
- Persist and reuse cached schedule/results
- Adaptive refresh interval (daily vs hourly)

---

## Manual refresh

Widgets support a `Refresh Now` App Intent (`RefreshNowIntent`) that:

- sets a `force-refresh` flag in shared defaults
- calls `WidgetCenter.shared.reloadAllTimelines()`

The next timeline build consumes that flag and forces API refresh.

---

## Validation and diagnostics

1. **Widget timeline refresh checks**
   - Add widgets on macOS and iOS.
   - Trigger `Refresh Now` intent and verify updates.

2. **Xcode runtime logs**
   - Run host app + widget extension for each platform.
   - Inspect console for network failures, decoding failures, and timeline reload behavior.

3. **Unified logging**
   - Use Console.app / device logs filtered by bundle identifiers.
   - Verify no sensitive payloads are printed and failures remain generic.

4. **Network behavior checks**
   - Confirm only `https://api.openf1.org/v1/*` requests are made.
   - Confirm fallback UI appears when offline/API unavailable.

---

## Wrap-up docs

- `LICENSE` — GPL-3.0-or-later
- `PROMPT.md` — minimal meaningful prompt to reproduce this outcome
- `SECURITY_OWASP_TOP10.md` — OWASP Top 10 security assessment
- `TECHNOLOGIES.md` — technology inventory
- `CLI_BUILD_MACOS.md` — macOS CLI build/install/registration steps
