# Deprecated Archive

This folder keeps historical native macOS project/runtime assets that are no longer part of the active build path.

## Why archived

The project was simplified to an **iOS-first widget strategy** because it proved more reliable in production usage:

- Active targets: `OpenF1DashboardiOSApp` + `OpenF1DashboardiOSWidget`
- Active surfaces: iOS, iPadOS, and macOS via iPhone widgets on Mac
- Native macOS widget/app targets were deprecated and removed from generated project targets

## What is kept here

- `runtime-macos/` — old root-level native macOS runtime sources
- `template-macos/` — old Xcode template native macOS app/widget sources
- `docs/` — macOS-native specific build/deploy notes retained for reference

## Policy

- Archive is **reference-only**.
- Do not add new features here.
- All active development should target the iOS app/widget path.
