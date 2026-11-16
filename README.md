# Game-ANTS

A mobile-first ant-colony logic puzzle game.

**Working title:** ANTWORKS  
**Status:** Godot project bootstrap in progress  
**Repository:** MaiklLX/Game-ANTS

## Vision

Build an original, polished mobile puzzle game inspired by the broad gameplay space of ant-colony pixel puzzles. The project may learn from color-group selection, constrained queues, pixel-art boards, and satisfying swarm movement, but must develop its own rules, presentation, progression, and identity.

## Core pillars

1. **Readable strategy:** one-finger controls, clear rules, meaningful move order.
2. **Living colony:** ants visibly travel, gather, cooperate, and react to the board.
3. **Spatial logic:** routes, tunnel access, obstacles, and colony logistics create depth.
4. **Rewarding reveals:** each solved level delivers a strong visual payoff.
5. **Mobile quality:** responsive portrait-first UI, smooth performance, offline-capable core play.

## Project rules

- GitHub Issues are the single source of tasks and decisions.
- Agents work on isolated branches and submit pull requests.
- No agent may merge directly into `main`.
- Preserve checkpoints: every meaningful milestone gets a dated project note and a checkpoint phrase in the documentation.
- Do not copy another game's art, levels, text, branding, or exact implementation.
- Do not add monetization or analytics to the prototype until the core loop is validated.

## Current milestone

**KT-002 — Godot bootstrap and graybox foundation**

The project baseline is pinned to **Godot 4.7.2-stable (Standard)**. See [Local Setup](docs/SETUP.md) for installation and validation instructions.

See:
- [Game Design](docs/GAME_DESIGN.md)
- [Technical Plan](docs/TECHNICAL_PLAN.md)
- [Roadmap](docs/ROADMAP.md)
- [Agent Rules](AGENTS.md)

## Current status

The Godot project skeleton and launch placeholder are being developed on a feature branch. An internal Android Debug export preset and CI APK workflow are now configured; the first successful export and physical-device validation are still pending. The current launch scene remains a technical placeholder, not the finished game.
