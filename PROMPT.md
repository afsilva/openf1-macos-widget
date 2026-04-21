# Regeneration Prompts (iOS-first, current strategy)

Use these prompts to recreate the **current** OpenF1 widget outcome.

## 1) Master prompt (active architecture)

```text
Build a production-ready iOS-first WidgetKit project named OpenF1Dashboard, aligned to my openf1-gnome-extension behavior.

Platform/targets (active):
- iOS host app + iOS widget extension
- Shared logic/models module used by both

Usage surfaces:
- iOS + iPadOS natively
- macOS via iPhone widgets on Mac

Deprecation policy:
- Native macOS host app/widget path is deprecated and archived under _deprecated/ (reference-only).
- Do not generate active native macOS widget targets in project.yml.

Data source and behavior:
- Use OpenF1 API (https://api.openf1.org/v1), endpoints: meetings, sessions, session_result, drivers.
- Skip canceled sessions/weekends.
- Show upcoming weekend and next meaningful session.
- Build driver + constructor standings from race/sprint results.

Reliability and refresh:
- Cache-first reads with bounded cache size and bounded response size.
- Persist last-known-good model and fallback gracefully on failures.
- Include stale-cache rescue for transient API failures (schedule/results/directory).
- Refresh policy: daily off-weekend, hourly during/near race weekend.
- Manual refresh via AppIntent button in widget.

Security/OWASP controls:
- HTTPS-only fixed host.
- Endpoint allowlist + query validation.
- Sanitized UI text output.
- No secret/token handling in source or cache.
- Keep entitlements minimal and explicit (iOS app-group only for active path).

Widget UX requirements (iOS):
- Families: systemLarge + systemMedium.
- Medium should be summarized (not a cramped copy of large).
- Make Grand Prix subtitle stand out slightly without taking extra lines.
- Session-time rows must remain readable.
- Build-stamp line should be subtle/smaller.
- Disable default widget tap-through to app root (widgetURL nil) so only refresh control is interactive.

Host app text:
- Mention data source (OpenF1 public API URL).
- Mention open-source license (GPL-3.0-or-later).
- Keep text readable on iPhone/iPad (wrapping/scrolling; avoid truncation).

Deliverables:
- Source files for active iOS targets.
- XcodeGen project template and setup checklist.
- OWASP assessment doc + deployment docs.
- Prompt doc updated to reflect iOS-first constraints.

Validation:
- Build for iOS simulator + physical iPhone.
- Verify widget install/refresh behavior.
- Ensure no stale native macOS widget registrations remain in local environment.
```

---

## 2) Follow-up prompt (UI readability tuning)

```text
Tune iOS widget readability without changing core functionality:
- Increase session-time readability slightly.
- Make Grand Prix subtitle slightly more prominent while keeping single-line compact layout.
- Reduce visual dominance of build-stamp text.
- Keep medium iOS as summary view to avoid truncation.
- Apply changes in both runtime and template iOS widget files.
```

---

## 3) Follow-up prompt (interaction policy)

```text
Disable default widget tap-through to host app and keep only the refresh control interactive.
Apply this to active iOS widget runtime and template copies.
```

---

## Notes

- Keep `XcodeProjectTemplate/project.yml` as source of truth for generated targets/settings.
- Keep bundle IDs/team/app-group values configurable for local signing.
- Never commit signing secrets/profiles/cert files to git.
- Treat `_deprecated/` as reference-only archive.
