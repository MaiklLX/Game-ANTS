# Game-ANTS

A portrait-first continuous arcade puzzle where colorful ant swarms clear a pixel-art mosaic.

**Working title:** ANTWORKS  
**Status:** KT-016 Color Flow prototype — first playable loop in progress  
**Repository:** MaiklLX/Game-ANTS

## Vision

Build an original, polished mobile puzzle game inspired by the broad gameplay space of ant-colony pixel puzzles. The project may learn from color-group selection, constrained queues, pixel-art boards, and satisfying swarm movement, but must develop its own rules, presentation, progression, and identity.

## Core pillars

1. **Continuous flow:** ants move in real time, not turn by turn.
2. **Color matching:** each ant clears only pixels of its own color.
3. **Visible progress:** a pixel-art mosaic is gradually dismantled.
4. **Readable controls:** large color launchers, progress, pause, and speed control.
5. **Mobile quality:** portrait-first layout, smooth simulation, offline-capable core play.

## Project rules

- GitHub Issues are the single source of tasks and decisions.
- The owner has explicitly authorized direct iterative updates to `main` for this prototype so builds can be tested immediately.
- Keep meaningful checkpoints and preserve the old strategic prototype on its separate branch and Draft PR #12.
- Preserve checkpoints: every meaningful milestone gets a dated project note and a checkpoint phrase in the documentation.
- Do not copy another game's art, levels, text, branding, or exact implementation.
- Do not add monetization or analytics to the prototype until the core loop is validated.

## Current milestone

**KT-016 — Color Flow Arcade**

The launch scene now uses a continuous ant-flow prototype: select a color to release up to three ants; they seek and clear matching pixels from the mosaic. Pause and ×1/×2 speed controls are included.

The project baseline is pinned to **Godot 4.7.2-stable (Standard)**. See [Local Setup](docs/SETUP.md) for installation and validation instructions.

See:
- [Game Design](docs/GAME_DESIGN.md)
- [Technical Plan](docs/TECHNICAL_PLAN.md)
- [Roadmap](docs/ROADMAP.md)
- [Agent Rules](AGENTS.md)

## Current status

The first playable prototype is on `main`. It is an early mechanics slice, not a finished level system: queue/container rules, adjacency unlocks, richer ant paths, effects, and additional mosaics remain to be implemented. GitHub Actions is configured to validate the Godot project and build an Android debug APK from `main`; physical-device testing is still required.
