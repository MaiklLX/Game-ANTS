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

The initial scene is only a technical placeholder. It is not the final game menu or art direction.

## Android export

Android export is not configured in this bootstrap. It will require Android export templates and the Android SDK toolchain. Keep signing keys and passwords outside the repository; never commit them.

Official guide: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html

## Automated validation

GitHub Actions downloads the pinned official Godot 4.7.2 Linux headless binary, imports the project, and runs deterministic core tests, and launches the main scene in headless mode. This checks project parsing and scene startup; it does not replace visual testing on a phone.

## Known limitations

- No Android APK/AAB has been exported yet.
- No physical-device test has been performed.
- iOS export has not been configured or tested.
- The project currently contains a placeholder launch scene only.
