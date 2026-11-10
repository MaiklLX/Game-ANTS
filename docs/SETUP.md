# Local Setup

## Engine

Use Godot 4.7.2-stable (Standard, not .NET).

- Official release archive: https://godotengine.org/download/archive/
- Renderer: Compatibility (OpenGL), selected as a conservative baseline for mobile hardware.
- First target: Android phones, portrait orientation.
- iOS export is a later milestone and requires macOS/Xcode for final export and device validation.

## Open the project

1. Download and extract Godot 4.7.2-stable for your desktop OS.
2. Launch Godot and choose Import.
3. Select this repository's project.godot.
4. Open the project and press F6/F5 to run the current application.

The current application includes a Russian main menu, chapter selection, settings, pause flow, and the playable strategic campaign. It is still an active development build, not a store-ready release.

## Current game foundation

- 100 authored levels across four chapter packs.
- Explicit squad deployment, resource targets, and return orders.
- Simultaneous squad movement on one shared turn/day budget.
- Collection and delivery only on arrival; no autonomous dispatch.
- Campaign progress and accessibility settings stored locally.
- Reduced-motion and haptic-feedback preferences.
- One-turn undo and dedicated victory/retry flow.

## Android export

An internal Android Debug export preset is provided in export_presets.cfg.

- Preset: Android Debug
- Artifact: build/android/Game-ANTS-debug.apk
- Package ID: com.maikllx.gameants.debug (temporary internal QA ID; not the final store identity)
- App label: Муравьишки
- Architectures: ARMv7 and ARM64
- Signing: Godot debug signing only; no release keystore or production signing material is stored in the repository.
- CI: .github/workflows/android-debug.yml builds a debug APK on feature-branch pushes and manual dispatch; successful artifacts are retained for 14 days.
- Android SDK setup: CI installs platform-tools, Android API 35, and Build Tools 35.0.0.

The APK is for internal installation and testing only. It is not a store-ready release. Physical Android validation remains required.

Official guide: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html

## Automated validation

GitHub Actions runs:
- Godot project import and parsing;
- deterministic board, colony, strategic turn, and campaign tests;
- progress and settings persistence tests;
- tutorial, guidance, localization, and responsive-layout tests;
- campaign geometry/workload audit;
- headless main-scene launch;
- software-rendered portrait screenshots for app screens and gameplay;
- a separate Android debug export workflow.

Software-rendered screenshots and headless tests do not replace visual testing on a physical phone.

## Known limitations

- Android safe areas, system-bar behavior, touch targets, back navigation, and haptics still need physical-device QA.
- iOS export has not been configured or tested.
- Audio buses, sound effects, and music are not implemented; audio controls are intentionally not exposed yet.
- Cloud sync, accounts, online services, monetization, ads, and analytics are outside the current foundation.
