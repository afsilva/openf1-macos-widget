# Regeneration Prompts (Up-to-date)

Use these prompts to recreate the current OpenF1 widget outcome.

## 1) Master prompt (full unified outcome)

```text
Build a production-ready unified Apple widget project named OpenF1Dashboard, aligned to my openf1-gnome-extension behavior.

Platform/targets:
- macOS host app + macOS widget extension
- iOS host app + iOS widget extension
- Shared logic/models module used by all targets

Data source and behavior:
- Use OpenF1 API (https://api.openf1.org/v1), endpoints: meetings, sessions, session_result, drivers.
- Skip canceled sessions/weekends.
- Show upcoming weekend and next meaningful session.
- Build driver + constructor standings from race/sprint results.

Reliability and refresh:
- Cache-first reads with bounded cache size and bounded response size.
- Persist last-known-good model and fallback gracefully on failures.
- Refresh policy: daily off-weekend, hourly during/near race weekend.
- Manual refresh via AppIntent button in widget.

Security/OWASP controls:
- HTTPS-only fixed host.
- Endpoint allowlist + query validation.
- Sanitized UI text output.
- No secret/token handling in source or cache.
- Keep entitlements minimal and explicit (app groups, macOS sandbox/network).

Widget UX requirements:
- macOS widget: systemLarge.
- iOS widget: systemLarge + systemMedium.
- Medium iOS should be summarized (not a cramped copy of large).
- Make Grand Prix subtitle stand out slightly without taking extra lines.
- Session-time rows must remain readable.
- Build-stamp line should be subtle/smaller.
- Disable default widget tap-through to app root (widgetURL nil) so only refresh control is interactive.

Branding and consistency:
- Reuse the same icon artwork across macOS and iOS app icons.
- Keep typography and data hierarchy consistent across platforms.

Host app text:
- Mention data source (OpenF1 public API URL).
- Mention open-source license (GPL-3.0-or-later).
- Keep host app text readable on iOS (wrapping/scrolling; avoid truncation).

Deliverables:
- Source files for all targets.
- XcodeGen project template and setup checklist.
- OWASP assessment doc + deployment docs.
- Prompt doc updated to reflect final behavior and constraints.

Validation:
- Build for iOS + macOS.
- Verify simulator and physical iPhone deployment.
- Verify widget registration/install behavior and refresh action.
```

---

## 2) Follow-up prompt (UI readability tuning)

```text
Tune widget readability without changing core functionality:
- Increase session-time readability slightly.
- Make Grand Prix subtitle slightly more prominent while keeping single-line compact layout.
- Reduce visual dominance of build-stamp text.
- Keep medium iOS as summary view to avoid truncation.
- Apply changes in both runtime and template widget files for iOS and macOS.
```

---

## 3) Follow-up prompt (interaction policy)

```text
Disable default widget tap-through to host app and keep only the refresh control interactive.
Apply this to both iOS and macOS widgets, in runtime and template copies.
```

---

## Notes

- Keep `project.yml` as source of truth for generated project settings.
- Keep bundle IDs/team/app-group values configurable for local signing.
- Never commit signing secrets/profiles/cert files to git.
