# Game-ANTS — Муравьишки

A portrait-first ant-colony strategy puzzle built with Godot 4.7.2.

## Current direction

The player directs a small colony: deploy squads, assign matching-color seed targets, coordinate simultaneous expeditions, and explicitly order each return to the nest. Ants execute committed orders; they never autonomously choose a new target or return.

The experience is designed to be friendly, calm, tactile, and readable on mobile — strategic without tedious per-cell micromanagement.

## Current foundation

- 100 authored levels across four chapter packs.
- Deterministic turn engine with one shared day budget.
- Multiple active squads move simultaneously on committed turns.
- Explicit collection and return orders; no automatic dispatch.
- Route previews, carrying capacity, deployment slots, win/loss states.
- Persistent campaign progress by stable level IDs.
- Main menu, chapter selection, settings, gameplay, pause, and victory/retry result screens.
- One-turn undo that restores board, colony, active orders, and shared day budget.
- Reduced-motion and haptic-feedback preferences.
- Next-level continuation is saved after victory; undo restores the current level as the continue target.
- Responsive portrait layout and software-rendered mobile QA workflow.
- Offline campaign; no accounts or network dependency.

## Repository

- Repository: MaiklLX/Game-ANTS
- Working branch: feat/kt-015-strategic-puzzle
- Pull request: #12 (Draft; unmerged)
- main remains untouched.

## Development rules

- Keep changes on feature branches and preserve checkpoints.
- Do not merge or publish to main without explicit owner approval.
- Do not claim physical-device testing from headless CI.
- Keep game rules independent from animation and presentation.
- No monetization, ads, analytics, or online services until the core game is validated.

## Documentation

- Game Design: docs/GAME_DESIGN.md
- Technical Plan: docs/TECHNICAL_PLAN.md
- Roadmap: docs/ROADMAP.md
- KT-015 Strategic Puzzle: docs/KT_015_STRATEGIC_PUZZLE.md
- Local Setup: docs/SETUP.md
