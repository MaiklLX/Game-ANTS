# Local Setup

## Engine

Use **Godot 4.7.2-stable (Standard, not .NET)** for this project.

- Official release archive: https://godotengine.org/download/archive/
- Project renderer: Compatibility (OpenGL), selected as a conservative baseline for mobile hardware.
- First target: Android phones, portrait orientation.
- iOS export is a later milestone and requires macOS/Xcode for final export and device validation.

Godot 4.8 is currently a beta in the official archive; do not use a beta engine for this project baseline.

## Open the project

1. Download and extract Godot 4.7.2-stable for your desktop OS.
2. Launch Godot and choose **Import**.
3. Select this repository's `project.godot`.
4. Open the project and press **F6/F5** to run the current launch scene.

The current launch scene is the KT-016 Color Flow prototype: tap one of the three color launchers to send up to three ants toward matching pixels. Pause and ×1/×2 speed controls are available. This is an early mechanics slice, not the final art direction or complete ruleset.

## Android export

An internal **Android Debug** export preset is provided in `export_presets.cfg`.

- Preset: `Android Debug`
- Artifact: `build/android/Game-ANTS-debug.apk`
- Package ID: `com.maikllx.gameants.debug` (temporary internal QA ID; not the final store identity)
- Architectures: ARMv7 and ARM64
- Signing: Godot's debug signing only; no release keystore or production signing material is stored in the repository.
- CI: `.github/workflows/android-debug.yml` builds the APK on feature-branch pushes and manual dispatch; the artifact is retained for 14 days.
- Android SDK setup: CI installs `platform-tools`, Android API 35, and Build Tools 35.0.0. The obsolete legacy SDK package `tools` is intentionally excluded.

The APK is for installation and testing on Android devices only. It is not a store-ready release. The APK contains the current main-branch prototype. It is a debug build for testing, not a store-ready release.

Official guide: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html

## Automated validation

GitHub Actions downloads the pinned official Godot 4.7.2 Linux headless binary, imports the project, and runs deterministic board and level-data tests, and launches the main scene in headless mode. This checks project parsing and scene startup; it does not replace visual testing on a phone.

## Known limitations

- No successful Android APK export has been confirmed yet.
- No physical-device test has been performed.
- iOS export has not been configured or tested.
- The project currently contains one playable color-flow prototype level; the full queue/container mechanics and campaign progression are still in development.
