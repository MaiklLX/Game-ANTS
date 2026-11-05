# Technical Plan

**Version:** 0.1  
**Status:** Provisional; validate with a minimal mobile prototype

## 1. Engine recommendation

Use **Godot 4.x with GDScript** for the initial 2D, pixel-art, mobile-first prototype.

Why:
- lightweight 2D workflow and strong scene system;
- fast iteration for grid logic and touch UI;
- open-source toolchain without per-install engine royalties;
- Android export path and a viable iOS export path;
- GDScript keeps the prototype approachable and easy to review.

Do not lock an exact engine minor version until the development environment and export templates are checked. Re-evaluate only if a concrete technical blocker appears.

## 2. Target platforms

- Primary first validation: Android phones.
- Secondary target: iOS after the core loop and export pipeline are stable.
- Portrait orientation first.
- Offline-first campaign; no network dependency for core levels.

## 3. Architecture principles

Separate the project into clear layers:

- **Game rules:** board state, squad state, valid moves, route search, collection, win/loss.
- **Level data:** deterministic board layouts, objectives, squad queues, solution metadata.
- **Presentation:** grid rendering, ant sprites, trails, particles, sound, camera.
- **UI:** HUD, slots, pause, retry, level complete.
- **Persistence:** `ProgressStore` stores completed level IDs, last selected level, and first-session tutorial completion in a versioned local save. Settings and in-progress board snapshots remain future scope.

The simulation must not depend on animation completion or frame rate. Animations visualize already-determined state transitions.

## 4. Proposed modules

- `BoardModel`: grid dimensions, cells, resources, obstacles, gates.
- `ColonyModel`: nest, squads, capacity, active routes.
- `Pathfinder`: deterministic route finding and reachability.
- `TurnResolver`: validates and applies player actions.
- `LevelValidator`: checks level data and solvability metadata.
- `LevelLoader`: loads versioned local level resources.
- `GamePresenter`: translates state changes into visual effects.
- `ProgressStore`: local campaign progress with a versioned schema and stable level IDs.

Names may change as the implementation takes shape; boundaries should remain clear.

### Current local progress contract

- File: `user://campaign_progress.json`; schema version 1.
- Stores completed level IDs and the last selected level ID. It never stores array indices, so inserting or reorganizing chapter packs does not redirect a saved player to the wrong level.
- Writes use a temporary file and rotate the previous valid save to a backup. Malformed JSON is preserved in a `.corrupt` sidecar before recovery; an unsupported future schema is not overwritten.
- IDs removed from the current campaign are ignored safely. A missing or removed last-selected ID falls back to the first current level.
- The level picker displays completion marks and a cleared-level count. All 100 levels remain directly selectable; sequential unlock gating has deliberately not been introduced.
- Current scope does not include in-progress board snapshots, scores, stars, cloud sync, or settings. On restart, the last selected level reloads from its initial board state.


## 5. Determinism and testing

- Same level + same sequence of actions must produce the same result.
- Use stable ordering for pathfinding tie-breaks.
- Test blocked paths, unreachable resources, full slots, empty squads, partial loads, and terminal states.
- Add a headless test path for core rules where practical.
- Validate every authored level against its intended solution.

## 6. Performance and mobile UX

- Avoid one scene node per tiny pixel if it creates unnecessary overhead; benchmark a TileMap/mesh/custom draw approach.
- Use object pooling only when profiling demonstrates a need.
- Respect safe areas and variable portrait aspect ratios.
- Use touch targets suitable for small screens.
- Pause simulation and audio correctly when the app is backgrounded.
- Keep animations interruptible and avoid blocking input during nonessential effects.

## 7. Repository and automation

- GitHub Issues are the only task source.
- Feature branches and pull requests are mandatory.
- No direct agent commits to `main`; no autonomous merge.
- GitHub Actions should run project validation and tests on pull requests.
- Keep CI deterministic and avoid requiring signing secrets for ordinary validation.

## 8. Development workflow without external agents
The project will be developed directly with ChatGPT and the connected GitHub tools. DeepSeek Harness and other external autonomous coding agents are not part of the current plan. No local agent installation or complex agent infrastructure is required.

ChatGPT can inspect and edit repository text files, create branches, Issues, and pull requests, and review CI results through connected tools. Actual Godot editor execution, Android/iOS exports, and physical-device testing require a suitable local or hosted development environment; these must not be claimed until actually run and verified.
