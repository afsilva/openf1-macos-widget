# Minimal prompt for desired outcome

Use this prompt to reliably regenerate this project outcome:

```text
Build a production-ready macOS WidgetKit app named OpenF1Dashboard, matching the behavior of my openf1-gnome-extension.

Requirements:
1) Targets: macOS host app + widget extension + shared service/models.
2) Data: OpenF1 API endpoints meetings/sessions/session_result/drivers.
3) UX: single widget size only (systemLarge), compact race-weekend schedule, full standings list behavior, manual refresh button.
4) Reliability: cache-first, bounded cache, fallback to last known good model, refresh policy = daily off-weekend and hourly during/near race weekend.
5) Security: OWASP-aligned controls (endpoint allowlist, query validation, HTTPS only, sanitized output, bounded response size, no secret handling).
6) Packaging: include app icon assets and ensure icon appears for app and widget listing.
7) Deliverables: source files, Xcode project template, setup checklist, and CLI build steps.
8) Validation: verify only one widget registration is active and no stale DerivedData widget copies are used.
```

Notes:
- This is intentionally concise and outcome-focused.
- Keep all generated code and docs aligned to this prompt.
