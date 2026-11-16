# KT-016 — Color Flow Arcade

**Status:** Direction approved; implementation specification in progress  
**Project:** Game-ANTS — Муравьишки  
**Reference:** User-uploaded gameplay recording, 2026-11-16

## 1. Approved direction

Game-ANTS is fully moving away from turn-based squad expeditions. The new core is a continuous arcade-puzzle loop built around ant swarms, color matching, and progressive removal of a pixel-art picture.

The old strategic implementation is preserved in its existing branch and Draft PR #12. It is not merged, deleted, or overwritten. This branch starts from the shared campaign foundation, not from the strategic PR head.

## 2. What is directly visible in the reference video

- Portrait mobile gameplay.
- A large pixel-art image occupies the main play area.
- The picture is progressively dismantled/cleared as gameplay proceeds.
- Ants move as continuous streams and swarms, not as discrete turn-by-turn units.
- A lower HUD contains colored numbered cells/containers associated with the flow of ants.
- A pause control and a speed multiplier (shown as x2) are visible.
- Completing the board triggers a victory presentation and progression to another level.

## 3. What remains an implementation hypothesis

The recording does not conclusively establish every interaction rule of the lower colored cells. Their exact relationship to queue order, launch slots, ant counts, and player input must be validated against the intended design before those details are hard-coded.

Do not present inferred mechanics as facts from the video.

## 4. Design target for our own game

- **Board:** pixel-art image made of individually addressable colored cells/pixels.
- **Ant flow:** continuous, smooth movement with visible trails/animation; no turn counter or per-cell player movement.
- **Color matching:** an ant can clear only a compatible color.
- **Progress feedback:** cleared pixels visibly disappear or transform, making the image's reduction immediately legible.
- **Control strip:** large, readable lower controls for color/quantity/launch resources, with clear queue order and capacity.
- **Pacing:** pause and at least one speed mode; simulation time must be independent from render frame rate.
- **Completion:** clear all required pixels, then show a short, satisfying reveal/result transition.
- **Failure:** only when the player genuinely has no valid way to continue under the finalized rules; never due to animation timing or hidden random penalties.
- **Accessibility:** color is paired with shape, icon, or label where practical; avoid relying on color alone.

## 5. Previously established Ants-Pixel-Hunt rules to evaluate

These were specified for a separate prototype and are candidate design inputs, not yet automatically adopted into Game-ANTS:
- Five launch slots.
- Containers arrive sequentially and may auto-launch.
- Each container has a limited ant count.
- Colors unlock through adjacency.
- Ants match pixel colors.
- Loss occurs only when no launch slot is free and no valid moves/pixels remain.

Review these as a coherent set against the video before adoption. Do not silently merge projects or assume every rule is visible in the reference.

## 6. Technical architecture target

Separate simulation from presentation:
- PixelBoardModel: dimensions, pixel colors, remaining/cleared state, adjacency and unlock rules.
- AntFlowModel: ant agents, color, position, movement intent, target, and lifecycle.
- ContainerQueueModel: ordered color/count containers, five-slot capacity if approved, and launch eligibility.
- FlowResolver: deterministic validation and state transitions for launching, matching, clearing, and terminal states.
- GameSimulation: fixed-step or delta-safe simulation clock, pause and speed multiplier.
- GamePresenter: interpolated ant movement, trails, clearing particles, glow, and feedback.
- HUD: queue/slots, counts, pause, speed, progress, and result states.

Animation must never decide whether a pixel is cleared. The model commits the result; presentation visualizes it.

## 7. First playable milestone

1. Replace the old turn-based game screen with a dedicated continuous-flow prototype scene on this branch.
2. Render one authored pixel-art board.
3. Spawn a small number of colored ants and move them smoothly.
4. Make valid ants clear matching pixels with clear feedback.
5. Add the lower control strip and queue interaction only after its rules are specified.
6. Add pause, speed, progress, and completion.
7. Add automated tests for color matching, pixel removal, invalid moves, queue capacity, pause/speed determinism, and win/loss.
8. Validate portrait layout at multiple aspect ratios and inspect software-rendered screenshots.

## 8. Explicitly out of scope for the first slice

- Turn-based days, squads, expeditions, and per-turn undo.
- Online services, ads, monetization, leaderboards, and accounts.
- Copying the reference game's exact artwork, level layouts, interface, names, or proprietary assets.
- Claiming physical Android/iOS testing without an actual device test.

## 9. Checkpoint and safety

- Working branch: feat/kt-016-color-flow-arcade
- Base: feat/kt-006-scalable-campaign-catalog
- Strategic prototype: Draft PR #12 remains preserved and unmerged.
- main is untouched.