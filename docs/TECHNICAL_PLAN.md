# Technical Plan

**Version:** 0.2  
**Engine:** Godot 4.7.2-stable  
**Status:** Active implementation on feat/kt-015-strategic-puzzle

## 1. Platforms and delivery

- Android portrait is the first release target.
- Core campaign is offline-first; no network connection is required to play authored levels.
- iOS export and desktop/web builds are future validation targets.
- Ordinary validation does not require signing secrets. Debug APK export is a separate CI workflow.
- No direct commits to main; work remains on a feature branch and is reviewed through a draft PR.

## 2. Runtime layers

### Rules and simulation
- BoardModel: grid geometry, resources, blocked cells, deterministic pathfinding.
- ColonyModel: squad roster, carrying capacity, deployment slots, movement, delivery.
- StrategicTurnEngine: explicit orders, shared day budget, deterministic simultaneous turn resolution.
- TurnResolver: objective completion and terminal outcome checks.
- LevelDefinition / LevelLoader: validation and loading of authored JSON levels.

Rules are independent of rendering and animation. The simulation commits state first; presentation visualizes the resulting transition.

### Campaign and persistence
- CampaignCatalog expands a manifest and chapter packs into stable level records.
- ProgressStore stores completed level IDs, last selected level ID, and tutorial completion.
- SettingsStore stores accessibility/feedback preferences; currently reduced motion and haptic feedback.
- Saves use temporary writes and preserve a previous valid version. Corrupt data is preserved before recovery; unsupported future schemas are not overwritten.

### Presentation and app shell
- game_screen.gd currently owns responsive custom-drawn UI and interaction routing.
- App states: main menu, chapter selection, settings, gameplay, pause.
- App focus loss/backgrounding stops automatic expedition playback and opens pause.
- Reduced motion changes movement transition duration; haptic feedback is invoked only for meaningful actions and only when enabled.
- Gameplay state, rules, and progress are not reset by opening settings or pausing.

## 3. Persistence contracts

### Campaign progress
- File: user://campaign_progress.json, schema version 1.
- Stores completed stable level IDs, last selected stable level ID, and tutorial completion.
- Never stores campaign array indices.
- Preserves a previous save as .bak; malformed JSON is preserved as .corrupt.
- Unsupported future schemas are left intact and disable writes.

### Settings
- File: user://app_settings.json, schema version 1.
- Current keys: reduced_motion, haptics_enabled.
- Defaults: reduced motion off; haptics on.
- Unknown keys are rejected by the runtime API. Unsupported future schemas are not overwritten.
- Settings are independent of campaign progress.

## 4. Input and lifecycle

- Touch and mouse share the same hit-test path.
- Escape/Back opens pause during gameplay and resumes from pause.
- App focus loss or backgrounding stops auto-run and pauses the session.
- Auto-run only advances existing explicit orders; it never chooses targets or issues new orders.
- Animation is not allowed to block the rules engine; input is gated only while a committed movement animation is resolving.

## 5. Testing strategy

- Headless tests for board, level schema, colony, turn engine, campaign catalog, progress persistence, settings persistence, and tutorial contracts.
- Campaign audit checks geometry/signature duplication and route/workload progression.
- CI imports the project, runs tests, audits the campaign, launches the main scene, and captures software-rendered portrait layouts.
- Android debug export is independent from validation.
- CI screenshots are software-rendered viewport captures, not proof of physical-device behavior.

## 6. Near-term architecture backlog

1. Split the monolithic screen controller into app navigation, gameplay presenter, and reusable UI components without changing game rules.
2. Add a robust turn snapshot/undo contract after the turn engine exposes safe serialization.
3. Add pause-safe audio lifecycle and sound buses before exposing audio settings.
4. Add a dedicated level-result/reward presentation and chapter completion summary.
5. Validate Android system-bar/safe-area behavior on physical devices.
6. Add automated level solvability proofs under the strategic turn rules, not only the legacy campaign solver.

## 7. Explicit non-goals

No accounts, cloud sync, online services, monetization, ads, analytics, procedural generation, or external autonomous coding agents in the current foundation.
