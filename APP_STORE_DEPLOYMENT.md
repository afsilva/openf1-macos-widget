# App Store / Distribution Guide (iOS-first)

This project now ships through the **iOS app + iOS widget** path.

Supported surfaces:
- iPhone
- iPad
- macOS via iPhone widgets on Mac

Native macOS widget packaging is deprecated for this repo.

---

## 1) Xcode targets

Use only:
- `OpenF1DashboardiOSApp`
- `OpenF1DashboardiOSWidget`

---

## 2) Signing

For both targets:
- Select Team
- Use unique bundle IDs
- Enable automatic signing
- Ensure App Group entitlement is identical on both

---

## 3) Pre-release checks

- Widget installs and renders on medium + large
- Manual refresh action works
- Cache fallback works offline
- Session time order is `System / Local / UTC`
- Build stamp follows `bYYYY.MM.DD-ios-NNN` and resets to `001` on date change
- No signing artifacts are committed to git
- No personal `DEVELOPMENT_TEAM` value is committed to tracked config
- API source / license text visible in host app

---

## 4) App Store Connect

- Upload iOS build (app + widget extension)
- Validate widget metadata/screenshots
- Submit via normal iOS/TestFlight pipeline

---

## 5) macOS note

macOS users access widget surface through iPhone widgets on Mac.
No separate native macOS widget submission is required in this strategy.
