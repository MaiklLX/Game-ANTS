# Roadmap and Checkpoints

## Milestone sequence

### KT-001 — Product and repository foundation
- [x] Confirm repository identity: `MaiklLX/Game-ANTS`
- [x] Establish GitHub Issues as the only task source
- [x] Write initial game direction and technical recommendation
- [x] Define agent branch/PR rules
- [ ] Validate engine choice in a local development environment
- [x] Create initial implementation Issues #1–#3

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
**Status:** Initial concept, repository rules, and Issues #1–#3 documented. No engine project or playable build exists yet.

**Completed**
- Created project README on `main`.
- Created foundation branch.
- Added game design, technical plan, roadmap, and agent operating rules.
- Created GitHub Issues #1–#3 for the first implementation sequence.

**Known limitations**
- External coding agents and DeepSeek Harness are explicitly deferred; development proceeds with ChatGPT and GitHub tools.
- Engine choice is a reasoned recommendation, not yet validated on the user's machine.
- Game mechanics are proposals until a playable graybox is tested.

**Next**
1. Execute Issue #1: validate the Godot toolchain and bootstrap the project.
2. Execute Issue #2: implement the deterministic board model.
3. Execute Issue #3: prototype squad selection, slots, and collection.

**Checkpoint phrase for a new chat:**

`GAME-ANTS — KT-001 FOUNDATION. Continue from branch foundation/kt-001-game-direction. GitHub Issues are the only task source. Development is handled directly with ChatGPT and GitHub tools; no DeepSeek Harness or external coding agent. Next: validate Godot 4.x setup and begin KT-002 graybox prototype. Preserve all approved design and agent rules. Never merge to main without owner approval.`


### KT-002 — Bootstrap started (2026-11-05)
**Branch:** `feat/kt-002-godot-bootstrap`  
**PR:** [#5 — Godot 4.7.2 mobile project bootstrap](https://github.com/MaiklLX/Game-ANTS/pull/5)  
**Base:** `foundation/kt-001-game-direction` (stacked on open PR #4)

**Completed in the branch**
- Pinned the project baseline to Godot 4.7.2-stable (Standard); 4.8 is still beta.
- Added portrait project settings (720 × 1280) and Compatibility renderer.
- Added a minimal launch placeholder scene.
- Added local setup and Android export notes.
- Added a headless GitHub Actions validation workflow.
- Added ignore rules and starter folder guides.

**Verification status**
- Files are committed and visible in the GitHub branch.
- No CI run has been confirmed yet.
- Godot editor launch, Android export, and physical-device checks remain unverified.
- No APK or gameplay build exists.

**Next**
1. Confirm the workflow executes and fix any parse/import failures.
2. Open the project in Godot 4.7.2 and visually inspect portrait layout.
3. Once the bootstrap is verified, proceed to the deterministic board model (Issue #2).

**Checkpoint phrase for a new chat:**

`GAME-ANTS — KT-002 BOOTSTRAP IN PROGRESS. Continue from branch feat/kt-002-godot-bootstrap and draft PR #5, based on foundation/kt-001-game-direction. Godot 4.7.2-stable is pinned. Project settings, portrait placeholder scene, setup guide, folder guides, and headless CI workflow are committed. CI and local/device launch are not yet verified. Keep PR #4 as the foundation dependency. GitHub Issues remain the only task source. No external agents. Never merge to main without owner approval.`


### KT-002 — CI and core model hardening (2026-11-05)
- Corrected the workflow to run for PRs targeting both `main` and `foundation/**`, so stacked PR #5 is included.
- Fixed the CI executable lookup by creating the `godot` command symlink after extracting the official Linux binary.
- Added deterministic `BoardModel` BFS pathfinding with a fixed neighbour order (up, right, down, left).
- Added a headless test script for boundaries, deterministic shortest paths, obstacle detours, unreachable goals, and same-cell routes.
- CI now executes the board-model test script before launching the main scene.

**Still unverified:** GitHub has not yet surfaced a workflow run through the available status endpoint. No successful engine execution is claimed. Android export and device testing remain pending.

**Updated checkpoint phrase:**

`GAME-ANTS — KT-002 BOOTSTRAP + BOARD MODEL. Continue from feat/kt-002-godot-bootstrap and draft PR #5, based on foundation/kt-001-game-direction. Godot 4.7.2-stable is pinned. Portrait Godot project, placeholder scene, setup guide, folder structure, CI workflow, deterministic BoardModel BFS, and headless board tests are committed. CI status is not yet confirmed; no local engine run or APK is claimed. Next: verify GitHub Actions execution, fix any parser/test failures, then expand Issue #2 board rules. PR #4 remains the foundation dependency. GitHub Issues only; no external agents; never merge to main without owner approval.`


### KT-002 — First green Godot CI run (2026-11-05)
**Status: PASS — Godot CI**

- Workflow run **#20** completed successfully: [open GitHub Actions run](https://github.com/MaiklLX/Game-ANTS/actions/runs/41997296164).
- Godot 4.7.2 Linux binary downloaded and version check passed.
- Project import and scene parsing passed.
- Deterministic BoardModel tests passed.
- Main scene launched successfully in headless mode.
- This confirms the project can be validated on GitHub's runner without a local Godot installation in the assistant environment.
- Still not covered: visual inspection in the editor, Android export, and physical-device testing.

**Next implementation step:** continue Issue #2 on a separate stacked feature branch for versioned level data and tile validation. Keep PR #5 as the engine/bootstrap dependency until reviewed.


### KT-003 — Versioned level data started (2026-11-05)
**Branch:** `feat/kt-003-level-data-schema`  
**Stacked on:** `feat/kt-002-godot-bootstrap`

- Added schema-v1 JSON level validation with board bounds, typed tiles, unique coordinates, valid start/goal, and resource counting.
- Added sample level `levels/level_001.json`.
- Added `docs/LEVEL_FORMAT.md` with field definitions and constraints.
- Added headless tests for valid sample data, duplicate coordinates, out-of-bounds goal, and unsupported schema version.
- Expanded CI to run level-data tests and include PRs based on `feat/**`.

**Verification:** pending GitHub Actions run for this branch. Do not call Issue #2 complete until CI passes and the remaining resource/board integration is reviewed.

**Checkpoint phrase:**

`GAME-ANTS — KT-003 LEVEL DATA IN PROGRESS. Continue from feat/kt-003-level-data-schema, stacked on feat/kt-002-godot-bootstrap and PR #5. Added LevelDefinition schema-v1 validation, sample level JSON, format documentation, and headless tests; CI is pending. Preserve Godot 4.7.2 baseline and deterministic BoardModel. Verify CI before expanding resource collection and board integration. PR #4 and PR #5 remain dependencies. GitHub Issues only, no external agents, never merge to main without owner approval.`


### KT-003 — Synchronous validation test runner (2026-11-05)
**Branch:** `feat/kt-003-level-data-schema`

- Simplified the level validation test entry point to match the already-used synchronous `SceneTree._initialize()` pattern in the BoardModel test runner.
- Removed deferred startup and the custom deferred finish path from the level test script.
- Added explicit negative cases for zero-width boards and unsupported tile types.
- The workflow still applies a 60-second timeout to each test command.

**Verification:** commit `aea97070f8e61566204332d69d3d4f2a890b3d05` was pushed to the feature branch. The available workflow/status endpoints have not yet returned a run or status for this commit. This is a test-harness simplification, not proof that the prior hang's root cause is known or that CI now passes.

**Next**
1. Recheck the GitHub Actions run for this commit and inspect job logs if it fails or times out.
2. Only after a green run, integrate level data with BoardModel and resource collection.
3. Keep PRs stacked and draft until reviewed; do not merge to `main`.

**Checkpoint phrase:**

`GAME-ANTS — KT-003 TEST RUNNER HARDENED, CI PENDING. Continue from feat/kt-003-level-data-schema, stacked on feat/kt-002-godot-bootstrap. Commit aea97070f8e61566204332d69d3d4f2a890b3d05 makes the level validation test runner synchronous like the existing BoardModel runner and adds invalid-dimension and invalid-tile cases. The 60-second CI timeout remains. No passing CI result is confirmed yet; inspect the next GitHub Actions run before integrating resource collection. Godot 4.7.2-stable remains pinned. PR #4/#5 dependencies remain; GitHub Issues only; no external agents; never merge to main without owner approval.`


### KT-003 — Level validation CI green (2026-11-05)
**Branch:** `feat/kt-003-level-data-schema`  
**Fix commit:** `a170734a6c0d6b4ad4e465b74724addbaa8aff35`

**Root cause identified**
- The valid-sample assertion interpolated an `Array` directly with the GDScript `%` formatting operator.
- Godot interpreted the array as a list of formatting arguments and raised `not all arguments converted during string formatting`.
- Because the script errored before reaching its final `quit(0)`, the CI timeout then terminated the test process. The timeout was a symptom, not the root cause.

**Fix**
- Convert the validation error array to a string before interpolation: `str(result["errors"])`.
- No engine version, project settings, or runtime architecture changes were made.

**Verification: PASS**
- GitHub Actions run **#43** completed successfully: [open run](https://github.com/MaiklLX/Game-ANTS/actions/runs/41999874203).
- Godot 4.7.2 download and version check passed.
- Project import and parsing passed.
- Deterministic BoardModel tests passed.
- LevelDefinition validation tests passed.
- Main scene headless launch passed.

**Next**
1. Integrate validated level data with BoardModel in a separate focused change.
2. Add resource collection rules only with tests for deterministic outcomes and invalid states.
3. Keep PRs stacked and draft until reviewed; do not merge to `main`.

**Checkpoint phrase for a new chat:**

`GAME-ANTS — KT-003 LEVEL DATA CI GREEN. Continue from feat/kt-003-level-data-schema, stacked on feat/kt-002-godot-bootstrap. Fix commit a170734a6c0d6b4ad4e465b74724addbaa8aff35 converts the validation error array to str() before GDScript string formatting; this fixed the actual test failure (the 60-second timeout was only a symptom). GitHub Actions run #43 passed: Godot 4.7.2 download/version, project import, BoardModel tests, LevelDefinition tests, and headless main-scene launch. Next: integrate level data with BoardModel, then build deterministic resource collection with tests. Preserve Godot 4.7.2; keep PR #4/#5 dependencies; GitHub Issues only; no external agents; never merge to main without owner approval.`
