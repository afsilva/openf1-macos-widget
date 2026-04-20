# Release Notes — iOS-first simplification

## Summary

This release simplifies OpenF1 Dashboard to a single active widget strategy:

- Active: iOS app + iOS widget extension
- Covers: iOS, iPadOS, and macOS usage via iPhone widgets on Mac
- Deprecated: native macOS widget target path

---

## Why

The iOS widget implementation proved more reliable in real-world usage.
Maintaining parallel native macOS widget behavior added complexity and inconsistency.

---

## Included changes

- XcodeGen template now generates iOS targets only
- Setup/deployment documentation switched to iOS-first flow
- Native macOS widget path documented as obsolete/deprecated
- Reliability hardening remains in shared data service logic

---

## Operational impact

- Fewer targets to sign and maintain
- Fewer widget registration collisions in development
- Simpler distribution and testing path
