# App Store Deployment Guide (macOS)

This guide is tailored for `openf1-macos-widget`.

## 1) Apple Developer prerequisites
- Active Apple Developer Program membership
- App Store Connect access for your team
- A unique bundle ID for app and widget extension

## 2) App identity and signing
In Xcode (project + both targets):
- Team: your paid developer team
- Signing: Automatic (recommended)
- App target bundle ID: e.g. `com.afsilva.OpenF1DashboardApp`
- Widget target bundle ID: e.g. `com.afsilva.OpenF1DashboardApp.widget`
- Ensure entitlements are valid for distribution:
  - app sandbox enabled
  - network client enabled
  - app group only if actually used and consistently configured

## 3) Versioning
Before each submission:
- Increase `CFBundleShortVersionString` (marketing version)
- Increase `CFBundleVersion` (build number)
- Keep app and widget versions aligned

## 4) App Store Connect setup
Create app in App Store Connect:
- Platform: macOS
- Name: OpenF1Dashboard
- Primary language, SKU, bundle ID
Then fill:
- App description
- Keywords
- Support URL / marketing URL
- Privacy policy URL

## 5) Privacy and compliance
- Complete App Privacy questionnaire in App Store Connect
- If app collects no personal data, declare accordingly
- Export compliance: likely "No" for proprietary encryption (TLS via system APIs), confirm in submission workflow

## 6) Archive and validate
In Xcode:
- Scheme: `OpenF1DashboardApp`
- Destination: Any Mac (Archive)
- Product -> Archive
In Organizer:
- Validate App
- Resolve any signing/capability/warning issues

## 7) Upload build
From Organizer:
- Distribute App -> App Store Connect -> Upload
- Wait for processing in App Store Connect

## 8) Metadata and screenshots
Provide:
- macOS screenshots (required sizes)
- App icon (already prepared)
- Category and content rights info
- "What’s New" text for each release

## 9) TestFlight (recommended)
- Enable internal testing first
- Verify widget behavior after install/update
- Confirm no stale widget registrations from dev builds

## 10) Submit for review
- Select processed build
- Complete all required compliance/privacy fields
- Submit for review

---

## Project-specific pre-submit checklist
- [ ] Only one widget family intended (`.systemLarge`) and visible in gallery
- [ ] Widget listing icon appears correctly
- [ ] Refresh behavior stable (cache-first, no rapid retry loops)
- [ ] App launches without Xcode attached
- [ ] No debug-only strings left (build stamps optional by your choice)
- [ ] Remove any local/dev artifacts from release branch
- [ ] Widget registration path is installed-app only (no active `DerivedData` registration)

---

## Optional next step
I can generate a release-ready checklist for your exact current branch, including:
- exact version numbers to set,
- final metadata text draft,
- and a submission-day runbook.
