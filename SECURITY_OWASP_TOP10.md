# Security assessment — OWASP Top 10 (2021)

Scope: `openf1-macos-widget` (host app + widget + shared service)

Assessment result: **PASS (with low-risk notes)**

## A01: Broken Access Control — PASS
- App is read-only against public OpenF1 endpoints.
- No role/privilege model, no local privileged operations.

## A02: Cryptographic Failures — PASS
- API base is fixed HTTPS (`https://api.openf1.org/v1`).
- No secrets/tokens in code or cache.

## A03: Injection — PASS
- Endpoint path/query is allowlisted and validated.
- User-facing text is sanitized before UI rendering.

## A04: Insecure Design — PASS
- Cache-first design with controlled refresh cadence.
- Failure handling uses graceful fallback and last-known-good model.

## A05: Security Misconfiguration — PASS
- Explicit request timeout and response-size bounds.
- App/widget sandbox enabled.
- Network client entitlement enabled for required outbound traffic.

## A06: Vulnerable and Outdated Components — PASS (process dependent)
- Uses Apple platform frameworks (SwiftUI/WidgetKit/AppIntents/Foundation).
- No third-party package manager dependencies in repo.
- Ongoing pass status depends on keeping Xcode/macOS SDK updated.

## A07: Identification and Authentication Failures — PASS (N/A)
- No auth/login/session/token workflows.

## A08: Software and Data Integrity Failures — PASS
- Typed decoding via `Codable` models.
- Bounded on-disk cache size and entry caps.
- No dynamic code loading.

## A09: Security Logging and Monitoring Failures — PASS (developer-ops note)
- Errors are surfaced safely and generically in UI.
- Runtime diagnostics supported via Xcode/Console logs.
- Recommendation: add explicit release logging policy if distributing publicly.

## A10: SSRF — PASS
- Host/domain is fixed and not user-controlled.
- Endpoint allowlist restricts request targets.

---

## Additional controls observed
- Response body hard cap (1 MB)
- Cache size cap
- Endpoint-entry cap
- Sanitized text output
- App-group/shared defaults usage with safe fallbacks
- Stale-cache rescue path for schedule/results/driver directory when transient API failures occur
- Last-known-good standings reuse to avoid empty scoreboard regressions during refresh

## Residual risks / recommendations
1. Keep app + widget entitlements minimal (principle of least privilege).
2. Maintain platform updates (Xcode/macOS SDK).
3. Add optional telemetry/structured logs for production observability.
4. If future auth is added, reassess A01/A07/A08 immediately.
