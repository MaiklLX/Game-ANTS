# KT-013 — Russian, fullscreen and visual upgrade

**Status:** implementation in progress; latest CI and Android export are being revalidated.  
**Branch:** `feat/kt-006-scalable-campaign-catalog`  
**Scope:** improve the playable Android build without changing campaign rules or save data.

## Implemented

- Enabled Android edge-to-edge presentation; the existing immersive-mode export option remains enabled.
- Kept the responsive safe-area transform so the playable interface stays clear of camera cutouts and device edges.
- Added `localization/ru.json` with Russian titles and objectives for all 100 campaign levels and all four chapter titles.
- Localized the main game interface, tutorial, squad/color labels, contextual hints, common gameplay errors and progress messages.
- Added `tests/test_russian_localization.gd` and wired it into the Godot validation workflow. It verifies that every catalog level and chapter has Russian text.
- Changed the Android launcher label to **Муравейник**.
- Enriched the procedural field surface with additional root, grass, soil-grain and highlight details; added depth accents to ants, seeds and the nest.

## Preservation

- No gameplay rules, level geometry, campaign order, or progress-save schema were intentionally changed.
- Work remains on the feature branch. PR #9 remains open and Draft; `main` has not been modified or merged.
- No release signing keys or release APK configuration were added.

## Validation

- The localization coverage test passed in GitHub Actions and reported all 100 levels and four chapters translated.
- A headless scene validation exposed an accidental rename of the internal `carried` squad-data key during a UI text replacement. The key was restored in commit `16461ee3e437bad16ea72b7dc6acb7f680be3957`; the latest validation and Android export must pass before distributing this build.
- Physical-device checks for safe-area behavior, touch targets and visual readability remain necessary after the new APK is installed.

## Checkpoint phrase

`GAME-ANTS — KT-013 — RUSSIAN + IMMERSIVE + VISUAL — BRANCH feat/kt-006-scalable-campaign-catalog — HEAD 16461ee3e437bad16ea72b7dc6acb7f680be3957 — PR #9 DRAFT — MAIN UNTOUCHED — WAITING FOR LATEST CI/APK`
