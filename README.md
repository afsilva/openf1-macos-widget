# OpenF1 Dashboard (macOS 26.4 Widget)

A WidgetKit-based macOS widget that follows the same product and reliability principles as `openf1-gnome-extension`:

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
- SwiftUI + WidgetKit + AppIntents

> Note: You create this in Xcode as a macOS app with a widget extension, then copy these source files into the app/widget targets.

---

## Project layout

```text
openf1-macos-widget/
  OpenF1Shared/
    OpenF1Models.swift
    OpenF1Service.swift
  OpenF1Widget/
    OpenF1Widget.swift
    RefreshNowIntent.swift
  OpenF1HostApp/
    OpenF1HostApp.swift
  XcodeProjectTemplate/
    project.yml
    SETUP_CHECKLIST.md
    Scripts/generate_xcodeproj.sh
    Config/*.plist + *.entitlements
    OpenF1DashboardApp/*
    OpenF1DashboardWidget/*
    OpenF1Shared/*
```

If you want the fastest setup path, use `XcodeProjectTemplate/` directly.

---

## Setup in Xcode

### Option A (recommended): Ready-to-import template

```bash
cd openf1-macos-widget/XcodeProjectTemplate
./Scripts/generate_xcodeproj.sh
open OpenF1Dashboard.xcodeproj
```

Then follow:
- `openf1-macos-widget/XcodeProjectTemplate/SETUP_CHECKLIST.md`

### Option B: Manual integration

1. Create a new **macOS App** project (SwiftUI lifecycle).
2. Add a **Widget Extension** target.
3. Add an **App Group** capability to both targets (example: `group.com.example.openf1widget`).
4. Copy files from this folder into your project:
   - `OpenF1Shared/*` into a shared group included in both app + widget targets
   - `OpenF1Widget/*` into widget target
   - `OpenF1HostApp/*` into app target
5. In `OpenF1Service.swift`, replace:
   - `AppGroupConfig.identifier`
   with your real App Group identifier.
6. Build and run the app, then add the widget from macOS widget gallery.

---

## Security review (OWASP Top 10 aligned)

This widget is a local macOS UI client with outbound HTTPS requests to OpenF1. It does not process credentials, auth tokens, payments, or arbitrary user-provided query input. The implementation applies OWASP-aligned controls:

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
- Keep macOS/Xcode/SDK dependencies updated.
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

This widget preserves the same core behavior:

- Skip fully canceled weekends
- Show next meaningful event/session
- Compute standings from OpenF1 `session_result`
- Enrich driver/team from `drivers` endpoint
- Persist and reuse cached schedule/results
- Adaptive refresh interval (daily vs hourly)

---

## Manual refresh

The widget supports a `Refresh Now` App Intent (`RefreshNowIntent`) that:

- sets a `force-refresh` flag in shared defaults
- calls `WidgetCenter.shared.reloadAllTimelines()`

The next timeline build consumes that flag and forces API refresh.

---

## Validation and diagnostics (macOS)

1. **Widget timeline refresh checks**
   - Add widget to desktop/Notification Center.
   - Trigger `Refresh Now` intent and verify the widget updates.

2. **Xcode runtime logs**
   - Run host app + widget extension from Xcode.
   - Inspect console for network failures, decoding failures, and timeline reload behavior.

3. **Unified logging (Console.app)**
   - Open **Console.app** and filter by process/bundle identifier for host app and widget extension.
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
- `CLI_BUILD_MACOS.md` — CLI build/install/registration steps on macOS
