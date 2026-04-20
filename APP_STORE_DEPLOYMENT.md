# App Store Deployment Guide (Unified Apple: macOS + iOS)

This guide is tailored for `openf1-macos-widget` in its unified Apple configuration.

## 1) Apple Developer prerequisites
- Active Apple Developer Program membership
- App Store Connect access for your team
- Unique bundle IDs for all targets
  - macOS app + widget
  - iOS app + widget

## 2) Identity, signing, and capabilities
In Xcode, for all targets:
- Team: your paid developer team
- Signing: Automatic (recommended)
- Set production bundle IDs (replace template `com.example.*` values)

### Required capabilities
- **App Groups** on all app/widget targets with same group ID (example):
  - `group.com.yourorg.openf1widget`

- **macOS app + widget only**:
  - App Sandbox enabled
  - Outbound Network Client enabled

## 3) Versioning
Before each submission:
- Increase `CFBundleShortVersionString` (marketing version)
- Increase `CFBundleVersion` (build number)
- Keep app + widget versions aligned per platform

## 4) App Store Connect setup
Create app records in App Store Connect:
- macOS app record
- iOS app record

Fill metadata:
- App description
- Keywords
- Support URL / marketing URL
- Privacy policy URL

## 5) Privacy and compliance
- Complete App Privacy questionnaire for each platform app record
- If collecting no personal data, declare accordingly
- Export compliance: usually "No" for custom crypto (uses platform TLS), confirm during submission

## 6) Archive and validate
### macOS
- Scheme: `OpenF1DashboardApp`
- Destination: Any Mac (Archive)
- Product -> Archive

### iOS
- Scheme: `OpenF1DashboardiOSApp`
- Destination: Any iOS Device (Archive)
- Product -> Archive

In Organizer:
- Validate each archive
- Resolve signing/capability warnings

## 7) Upload build
From Organizer:
- Distribute App -> App Store Connect -> Upload
- Wait for processing for each platform

## 8) Metadata and screenshots
Provide required screenshots for each platform/device class.
Ensure icon and widget screenshots reflect final UX.

## 9) TestFlight (recommended)
- Start with internal testing (both iOS + macOS builds)
- Verify widget behavior after install/update
- Verify refresh flow and offline fallback behavior

## 10) Submit for review
- Select processed builds
- Complete compliance/privacy fields
- Submit each platform app for review

---

## Unified pre-submit checklist
- [ ] Bundle IDs are production values (no `com.example.*`)
- [ ] App Group configured consistently across all 4 targets
- [ ] `AppGroupConfig.identifier` updated to production group in shared code
- [ ] Widget tap-through behavior matches product intent
- [ ] iOS medium and large widget readability verified on-device
- [ ] macOS widget readability verified on latest supported macOS
- [ ] No debug-only strings/build stamps left unintentionally
- [ ] No dev artifacts or stale simulator-only registrations
- [ ] OWASP checklist reviewed (`SECURITY_OWASP_TOP10.md`)
