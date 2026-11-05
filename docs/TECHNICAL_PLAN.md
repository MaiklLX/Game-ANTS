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
- **Persistence:** local progress and settings, versioned save schema.

The simulation must not depend on animation completion or frame rate. Animations visualize already-determined state transitions.

## 4. Proposed modules

- `BoardModel`: grid dimensions, cells, resources, obstacles, gates.
- `ColonyModel`: nest, squads, capacity, active routes.
- `Pathfinder`: deterministic route finding and reachability.
- `TurnResolver`: validates and applies player actions.
- `LevelValidator`: checks level data and solvability metadata.
- `LevelLoader`: loads versioned local level resources.
- `GamePresenter`: translates state changes into visual effects.
- `SaveService`: local progress/settings with schema version.

Names may change as the implementation takes shape; boundaries should remain clear.

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

## 8. Harness / coding agent

DeepSeek Harness is **not installed yet**. This repository is being prepared for it, but repository setup is not the same as installing or running the harness.

When installed, configure a dedicated Game-ANTS workspace and a separate GitHub identity with write access limited to this repository. The agent should read GitHub Issues, create an isolated branch/worktree, implement and test, then open a PR. It must not merge to `main`.

Never place access tokens or secrets in repository files or prompts.

## 9. DeepSeek Harness security
DeepSeek Harness is a developer-preview agent runtime, not a trusted sandbox. Its official safety notice warns that model-generated commands and plugins can access files, processes, credentials, and network resources made available to the runtime, and that sandboxing/approval controls do not guarantee isolation. Use a dedicated disposable or isolated Game-ANTS workspace, least privilege, a separate repository-scoped GitHub identity, and localhost-only Web UI access. Review current release advisories before installation; never expose broad personal credentials or install unreviewed plugins. Human approval remains mandatory for destructive actions, external writes, permission changes, and merges.
