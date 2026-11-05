# Roadmap and Checkpoints

## Milestone sequence

### KT-001 — Product and repository foundation
- [x] Confirm repository identity: `MaiklLX/Game-ANTS`
- [x] Establish GitHub Issues as the only task source
- [x] Write initial game direction and technical recommendation
- [x] Define agent branch/PR rules
- [ ] Validate engine choice in a local development environment
- [ ] Create first GitHub milestone and implementation issues

### KT-002 — Graybox gameplay prototype
- [ ] Initialize Godot project and mobile portrait settings
- [ ] Implement grid and level data model
- [ ] Implement squad selection and capacity/slot rules
- [ ] Implement deterministic pathfinding and collection
- [ ] Implement win/loss/retry flow
- [ ] Add 3 test levels and automated core-rule tests

### KT-003 — Signature mechanic validation
- [ ] Prototype pheromone routing
- [ ] Compare baseline puzzle vs pheromone puzzle
- [ ] Test readability and decision depth
- [ ] Keep or revise the mechanic based on playtest evidence

### KT-004 — Visual vertical slice
- [ ] Establish original art direction and ant silhouettes
- [ ] Add ant movement, carrying, trail, and collection animation
- [ ] Build polished HUD and level-complete presentation
- [ ] Test multiple portrait aspect ratios

### KT-005 — Content and progression
- [ ] Author and validate first 30 levels
- [ ] Add chapter progression and local save data
- [ ] Add sound and accessibility options
- [ ] Run device performance and usability checks

### KT-006 — Release readiness
- [ ] Android release pipeline and device QA
- [ ] iOS export and device QA
- [ ] Privacy, store listing, crash and regression checks
- [ ] Release candidate sign-off

## Checkpoint record

### KT-001 — 2026-11-05
**Branch:** `foundation/kt-001-game-direction`  
**Base commit:** `095c05feefbd6902b1462e513fd53f402f90f45e`  
**Status:** Initial concept and repository rules documented. No engine project or playable build exists yet.

**Completed**
- Created project README on `main`.
- Created foundation branch.
- Added game design, technical plan, roadmap, and agent operating rules.

**Known limitations**
- DeepSeek Harness is not installed.
- Engine choice is a reasoned recommendation, not yet validated on the user's machine.
- Game mechanics are proposals until a playable graybox is tested.

**Next**
1. Review and create GitHub Issues for KT-002.
2. Confirm local Godot setup and version.
3. Build the smallest playable loop before adding meta systems or content volume.

**Checkpoint phrase for a new chat:**

`GAME-ANTS — KT-001 FOUNDATION. Continue from branch foundation/kt-001-game-direction. GitHub Issues are the only task source. DeepSeek Harness is not installed; no autonomous merge to main. Next: validate Godot 4.x setup and begin KT-002 graybox prototype. Preserve all approved design and agent rules.`
