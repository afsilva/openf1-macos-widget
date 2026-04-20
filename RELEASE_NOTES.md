# Release Notes

## OpenF1 Dashboard — Unified Apple Release (macOS + iOS)

Date: 2026-04-20

## Highlights

- Evolved the project from macOS-only into a **unified Apple platform setup**.
- Added iOS host app + iOS widget extension while preserving shared behavior.
- Kept shared data/service logic in `OpenF1Shared` for consistency across platforms.
- Added iOS widget family support for:
  - `.systemLarge` (full dashboard)
  - `.systemMedium` (summarized dashboard)
- Synced iOS app icon set with macOS icon source for cross-platform visual consistency.
- Disabled default widget tap-through (`.widgetURL(nil)`) so only manual refresh control is interactive.

---

## Functional behavior

### Data source and model
- OpenF1 API endpoints: `meetings`, `sessions`, `session_result`, `drivers`
- Same race-weekend/next-session behavior as GNOME reference implementation
- Canceled session/weekend filtering retained
- Driver and constructor standings aggregated from race-like sessions

### Cache/refresh
- Cache-first retrieval
- Adaptive refresh policy:
  - Daily off-race-weekend
  - Hourly during/near race weekend
- Manual refresh via AppIntent (`RefreshNowIntent`)
- Last-known-good fallback model for degraded network/API periods

### Widget UX
- macOS: `.systemLarge`
- iOS: `.systemLarge` + `.systemMedium`
- Medium iOS layout is intentionally summarized to avoid truncation
- App launch tap-through disabled at widget root; explicit refresh button remains

---

## Security and compliance

Status: **OWASP Top 10 PASS (2021 mapping)**

Notable verified controls:
- HTTPS-only fixed OpenF1 host
- Endpoint allowlist + query validation
- Sanitized UI text output
- Bounded response and cache sizes
- Typed model decoding (`Codable`)
- App Group-backed shared cache/refresh flag path
- Sandboxing/network entitlements (macOS) and app-group entitlements (iOS/macOS)

See: `SECURITY_OWASP_TOP10.md`

---

## Build verification snapshot

Validated via CLI/Xcode tooling on this branch:
- `xcodegen generate` for unified project
- iOS compile/build validation
- macOS compile validation (`CODE_SIGNING_ALLOWED=NO` in local CLI environment)
- Simulator install/launch checks for iOS host app + widget flow

---

## Documentation updates included

- `README.md` updated to unified architecture and setup
- `XcodeProjectTemplate/SETUP_CHECKLIST.md` updated for all four targets
- `SECURITY_OWASP_TOP10.md` reviewed for unified platform controls
- `APP_STORE_DEPLOYMENT.md` updated for iOS + macOS packaging guidance
