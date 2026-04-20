# Release Notes

## OpenF1 Dashboard (macOS Widget) — Final Delivery

Date: 2026-04-20

## Highlights

- Delivered a macOS WidgetKit implementation aligned to the original `openf1-gnome-extension` behavior.
- Stabilized widget registration and packaging so one clean widget extension is active.
- Improved UI density and readability for sessions + standings.
- Finalized icon pipeline for both app and widget listing behavior.
- Added security, licensing, and CLI build documentation.

---

## Functional Changes

### Widget behavior and data
- Data source: OpenF1 API (`meetings`, `sessions`, `session_result`, `drivers`)
- Race-weekend logic and next-session selection aligned to GNOME principles
- Canceled weekend/session handling preserved
- Standings built from race/sprint session results with driver/team enrichment
- Added resilience for partial API failures (avoid all-or-nothing blank states)
- Added fallback to last-known-good model for smoother refresh behavior

### Refresh and caching
- Cache-first retrieval model with bounded cache controls
- Refresh cadence:
  - Daily off-weekend
  - Hourly during/near race weekend
- Manual refresh via App Intent (`RefreshNowIntent`)

### Widget UX
- Single supported family: `.systemLarge`
- Compact, consistent monospaced typography
- Session row font reduced for better space utilization
- Standings density improved
- Subtle border maintained
- Build stamp rendered in-widget for runtime verification

---

## Standings Display Update

- Drivers list expanded target to full championship set (22 entries)
- Teams list expanded target to full constructor set (11 entries)
- Driver rows rendered in compact paired layout for fit on large card
- Team rows rendered fully in right column

---

## Icon and Packaging Fixes

### App icon
- Regenerated readable icon style: “Open” on first line, “F1” on second line
- Full app icon asset set updated in `AppIcon.appiconset`

### Widget listing icon
- Fixed extension-side icon packaging:
  - Added icon keys to widget extension Info.plist
  - Added widget resource phase for asset catalog
  - Enabled app icon compilation for widget target
- Cleaned stale registrations and re-registered installed app extension

---

## Security Review (OWASP Top 10)

Status: **PASS (with low-risk notes)**

Implemented controls include:
- HTTPS-only host
- Endpoint allowlist + query validation
- Sanitized UI output
- Typed decoding and bounded response size
- Bounded cache sizes/entries
- Sandboxing and network client entitlements
- Graceful failure behavior without sensitive output exposure

See full assessment: `SECURITY_OWASP_TOP10.md`

---

## Licensing and Docs

- License updated to **GPL-3.0-or-later** (`LICENSE`)
- Minimal meaningful regeneration prompt documented (`PROMPT.md`)
- Technology inventory documented (`TECHNOLOGIES.md`)
- macOS CLI build/install/registration flow documented (`CLI_BUILD_MACOS.md`)

---

## Build and Distribution Notes

- Canonical project path: `openf1-macos-widget/XcodeProjectTemplate/`
- Build via `xcodebuild` (documented in `CLI_BUILD_MACOS.md`)
- Recommended install target: `~/Applications/OpenF1Dashboard.app`
- Verify single active widget registration via `pluginkit`

---

## Final Acceptance Snapshot

- Widget appears in gallery and runs
- Data rendering is stable and GNOME-aligned
- Icon is readable in app context
- Documentation and licensing finalized for handoff
