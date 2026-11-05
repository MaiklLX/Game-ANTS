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


### KT-003 — Level-to-board integration and resource state (2026-11-05)
**Branch:** `feat/kt-003-level-data-schema`  
**Implementation commits:** `c891c170b347b596bbac85bff5b90885cfdcaf71`, `b803aba5590cee634feed2fbdde406b4fde635f1`, `afa36a18df95fa73f01e78915e5016a0bdea0c40`

**Completed**
- Added transactional `BoardModel.load_level()`: validates the complete level before changing the current board.
- Loads dimensions, level ID, start/goal coordinates, obstacles, and resource cells from the versioned JSON data.
- Added deterministic resource-state queries and one-time collection with a remaining-resource counter.
- Added tests for level loading, obstacle application, shortest path on the loaded sample, resource collection exactly once, out-of-bounds collection, and preservation of the prior board after an invalid load.

**Verification: PASS**
- GitHub Actions run **#51** passed on the integration test commit: [open run](https://github.com/MaiklLX/Game-ANTS/actions/runs/42000064076).
- Project import, BoardModel tests, LevelDefinition tests, and headless main-scene launch all passed on Godot 4.7.2.

**Not yet implemented**
- Ant squads, slot/capacity rules, animated movement, carrying visuals, and player-facing win/loss flow.
- Resource collection is currently a deterministic core-state operation, not yet connected to ant movement or UI.

**Next**
1. Define and test squad selection and limited-slot rules independently of rendering.
2. Connect a squad's route to BoardModel pathfinding and resource collection.
3. Keep PRs stacked and draft until reviewed; do not merge to `main`.

**Checkpoint phrase for a new chat:**

`GAME-ANTS — KT-003 LEVEL-TO-BOARD INTEGRATION GREEN. Continue from feat/kt-003-level-data-schema, stacked on feat/kt-002-godot-bootstrap. BoardModel.load_level() now validates before mutation and loads level ID, dimensions, start/goal, obstacles, and resource cells. Resource state supports has_resource(), collect_resource() exactly once, and remaining_resources. Tests cover sample level loading, obstacles, shortest path, resource collection, out-of-bounds collection, and invalid-load state preservation. GitHub Actions run #51 passed on commit afa36a18df95fa73f01e78915e5016a0bdea0c40 with Godot 4.7.2, import, both core test scripts, and headless main-scene launch. Next: design/test ant squad selection and limited slots, then connect squad routes to collection. This is core logic only; no ant visuals or gameplay UI yet. PR #4/#5 dependencies remain; GitHub Issues only; no external agents; never merge to main without owner approval.`


### KT-004 — Deterministic squad slots and color-matched collection (2026-11-05)
**Branch:** `feat/kt-004-squad-rules`  
**Draft PR:** [#7 — prototype ant squad slots and collection rules](https://github.com/MaiklLX/Game-ANTS/pull/7)  
**Verified implementation commit:** `f2bc95c4e5afde3fc133133a9b8ed6d3f162785c`

**Completed**
- Added explicit resource colors to schema-v1 resource tiles: `amber`, `teal`, `coral`, and `violet`.
- BoardModel now retains resource colors and rejects collection by a mismatched color when one is supplied.
- Added `ColonyModel` for deterministic squad registration, validation, limited deployment slots, carrying capacity, reachable matching-resource collection, and return/delivery.
- A deployed squad occupies its slot until it returns; partial loads are delivered on return, and the slot is then released.
- Added tests for invalid squad definitions, duplicate IDs, slot exhaustion/release, wrong-color targets, empty targets, unreachable resources, carrying capacity, and partial delivery.
- Updated the level format documentation and CI workflow to run ColonyModel tests.

**Test-harness correction**
- An earlier run (#65) reported success despite assertion errors because the test helpers called `quit(1)` and then the script continued to a final `quit(0)`.
- Test helpers now accumulate failures and choose the process exit code only once at the end.
- Level validation now accepts integral JSON numeric values whether Godot represents them as integers or floats, while rejecting fractional values.

**Verification: PASS**
- GitHub Actions run **#74** passed: [open run](https://github.com/MaiklLX/Game-ANTS/actions/runs/42000863450).
- Log output explicitly confirms: `BoardModel tests passed.`, `LevelDefinition tests passed.`, and `ColonyModel tests passed.`.
- Godot 4.7.2 download/version, project import, all three test scripts, and headless main-scene launch passed.
- No local editor, Android export, or physical-device testing is claimed.

**Remaining**
- Squad rules are currently core simulation only. No ant movement animation, visual slots, UI selection, preview panel, undo, or win/loss flow is implemented yet.
- The exact squad/slot values remain level-configurable; the tests use two deployment slots and small capacities as prototype values, not final balance.

**Next**
1. Add a deterministic action/turn resolver that previews and applies a squad deployment/return action without animation dependencies.
2. Define explicit blocked and victory outcomes and cover them with tests.
3. Build the first graybox gameplay presentation only after the core action loop is stable.
4. Keep PRs stacked and draft until reviewed; do not merge to `main`.

**Checkpoint phrase for a new chat:**

`GAME-ANTS — KT-004 SQUAD CORE GREEN. Continue from feat/kt-004-squad-rules and draft PR #7, based on feat/kt-003-level-data-schema (PR #6 dependency). Resource tiles now require one of amber/teal/coral/violet. BoardModel tracks resource colors and supports color-aware collection. ColonyModel provides squad registration, two-or-more configurable deployment slots, capacity limits, reachable matching-color collection, partial-load delivery on return, and slot release. Strict test runners accumulate failures and exit nonzero; run #65 was a false-positive due to the old quit(1)/quit(0) pattern, corrected before verification. GitHub Actions run #74 passed with explicit BoardModel, LevelDefinition, and ColonyModel test success, Godot 4.7.2 import, and headless main-scene launch. Next: implement deterministic action/turn resolution plus explicit blocked/victory outcomes, then graybox UI. No animations/UI yet. PR #4/#5/#6 dependencies remain; GitHub Issues only; no external agents; never merge to main without owner approval.`


### KT-004 — Previewable turn resolution and terminal-state checks (2026-11-05)
**Branch:** `feat/kt-004-squad-rules`  
**Draft PR:** [#7 — prototype ant squad slots and collection rules](https://github.com/MaiklLX/Game-ANTS/pull/7)  
**Verified commit:** `bfe25c2cc5e573c467dbae127dc0d275e37874b5`

**Completed**
- Added `BoardModel.total_resources` and deterministic `get_resource_cells()` ordering.
- Added stable `ColonyModel.get_squad_ids()` for deterministic roster traversal.
- Added `TurnResolver.preview_collection()`: validates deployed state, capacity, target existence, color match, and reachability; returns the route and projected load without mutating game state.
- Added `TurnResolver.apply_collection()` to apply only a valid previewed collection.
- Added explicit terminal checks:
  - victory only after all resources have been collected, delivered to the nest, and all squads have returned;
  - blocked state when resources remain, no squad is deployed, and no idle squad can reach a matching resource.
- Added headless tests for preview immutability, deterministic route output, apply behavior, waiting-for-return victory, wrong-color blocked state, and unreachable-resource blocked state.

**Verification: PASS**
- GitHub Actions run **#86** passed: [open run](https://github.com/MaiklLX/Game-ANTS/actions/runs/42001237606).
- Logs explicitly confirm `BoardModel tests passed.`, `LevelDefinition tests passed.`, `ColonyModel tests passed.`, and `TurnResolver tests passed.`.
- Godot 4.7.2 download/version, project import, all four test scripts, and headless main-scene launch passed.
- No local editor, Android export, or physical-device testing is claimed.

**Remaining**
- The model is still headless core logic. There is no gameplay scene, visible slot UI, touch selection, ant movement animation, undo, or three authored sequencing levels.
- Blocked-state logic currently treats any deployed squad as still having a return action; UI must expose that action clearly.

**Next**
1. Add level-authored squad rosters and at least three tiny sequencing puzzles.
2. Implement a thin portrait graybox scene that renders the board and slots while delegating all outcomes to the tested core models.
3. Keep PRs stacked and draft until reviewed; do not merge to `main`.

**Updated checkpoint phrase for a new chat:**

`GAME-ANTS — KT-004 TURN RESOLVER GREEN. Continue from feat/kt-004-squad-rules and draft PR #7, based on feat/kt-003-level-data-schema (PR #6 dependency). Resource colors are explicit: amber, teal, coral, violet. BoardModel tracks resources and routes; ColonyModel provides squad roster, limited deployment slots, carrying capacity, matching-color reachable collection, partial-load return/delivery, and slot release. TurnResolver now provides non-mutating collection previews, validated apply_collection(), victory only after every resource is delivered and all squads return, and blocked detection when no deployed squad can return and no idle squad can reach a matching resource. Test runners accumulate failures and exit nonzero. GitHub Actions run #86 passed with explicit BoardModel, LevelDefinition, ColonyModel, and TurnResolver test success, Godot 4.7.2 import, and headless main-scene launch. Next: add level-authored squad rosters and three sequencing puzzles, then create a thin portrait graybox UI using the tested models. No visual ant movement or UI yet. PR #4/#5/#6 dependencies remain; GitHub Issues only; no external agents; never merge to main without owner approval.`


### KT-005 — First playable campaign graybox (2026-11-05)
**Branch:** `feat/kt-005-first-playable-levels`  
**Draft PR:** [#8 — build the first playable ANTWORKS campaign graybox](https://github.com/MaiklLX/Game-ANTS/pull/8)  
**Verified code head:** `1797f3234fade93971752186ed0eb8a92c1c2847`

**Completed**
- Extended schema v1 with player-facing `title` and `objective`, validated `deployment_slots` (1–4), and a validated roster of 1–8 uniquely identified squads with supported colors and capacity 1–9.
- Added `LevelLoader` to validate and load the board and colony roster together.
- Authored three meadow campaign levels:
  - `meadow_001`: learn deploy → collect → return.
  - `meadow_002`: choose the correct color squad with only one deployment slot.
  - `meadow_003`: collect two amber seeds with one two-capacity trip, then deliver one teal seed with a second trip.
- Replaced the foundation placeholder main scene with a portrait-first, touch/mouse graybox: visible deployment slots, squad cards, resource board, matching-color collection, nest return, delivery counter, retry, and level selection.
- Added a campaign test that loads all three level files through `LevelLoader` and solves each using the production `TurnResolver` and `ColonyModel` rules.
- Kept the game rules independent from the presentation layer. The UI draws the path/result; it does not own the rules.

**CI correction**
- Initial PR run #102 correctly caught that the legacy BoardModel tests expect `goal` to remain the authored target cell, not the nest.
- Restored each level's goal to its first authored target resource; the nest remains the return point represented by `start`.
- This preserves the existing BoardModel contract and keeps the new return interaction separate from the level goal field.

**Verification: PASS**
- GitHub Actions run **#107** passed: [open run](https://github.com/MaiklLX/Game-ANTS/actions/runs/42013559717).
- Logs explicitly confirm `BoardModel tests passed.`, `LevelDefinition tests passed.`, `ColonyModel tests passed.`, `TurnResolver tests passed.`, and `Campaign level tests passed.`.
- Godot 4.7.2 download/version, project import, all five test scripts, and headless main-scene launch passed.
- This is a headless CI validation. The scene has not yet been visually inspected in the Godot editor or on a physical Android device; no APK or public web build is claimed.

**Next**
1. Review the first playable screen at real phone aspect ratios and correct any layout/touch issues found in an actual editor/device run.
2. Improve the interaction feel: visible ant movement along the verified path, collection feedback, return-to-nest movement, and a clear blocked/retry state.
3. Add undo/state reset only after the action history can be tested deterministically.
4. Expand the first chapter beyond three levels once the basic loop feels good.
5. Web/PWA export remains a later parallel delivery target after the mobile game loop is stable; do not compromise Godot/mobile quality to accelerate it.

**Updated checkpoint phrase for a new chat:**

`GAME-ANTS — KT-005 FIRST PLAYABLE GRAYBOX GREEN. Continue from feat/kt-005-first-playable-levels and draft PR #8, based on feat/kt-004-squad-rules (PR #7 dependency). Godot 4.7.2-stable remains pinned. Level schema v1 now validates deployment_slots and squad rosters; LevelLoader loads board + colony from authored data. Three meadow levels exist: meadow_001 (basic collect/return), meadow_002 (two colors, one slot), meadow_003 (amber capacity-two trip plus teal trip). Main scene now uses scripts/ui/game_screen.gd for a portrait touch/mouse graybox with squad cards, slots, board, collection, nest return, delivery feedback, retry, and level picker. Campaign tests solve all three levels through production core models. GitHub Actions run #107 passed: BoardModel, LevelDefinition, ColonyModel, TurnResolver, Campaign level tests, Godot 4.7.2 project import, and headless main-scene launch. Initial run #102 caught a goal-field regression; goal coordinates were restored to authored target resources before the green run. No visual editor/device inspection, APK, or web deployment has been performed. Next: actual visual/device QA, then ant movement/collection/return feedback and improved game feel. Keep PRs stacked and draft; no merge to main without owner approval. GitHub Issues only; no external agents.`


### KT-005.1 — Continuous squad routes and visible ant movement (2026-11-05)
**Branch:** `feat/kt-005-first-playable-levels`  
**Draft PR:** [#8](https://github.com/MaiklLX/Game-ANTS/pull/8)  
**Verified implementation commit:** `bf411206372e771855c160ceeacddb5237d8c129`

**Completed**
- ColonyModel now stores each squad's current grid position, initializes it at the nest, advances it to each collected resource, and restores it to the nest on return.
- TurnResolver previews routes from the squad's actual current position, not always from the nest.
- The campaign solution test verifies that the second amber pickup in meadow_003 is reached by a one-cell continuation from the first pickup, and that each squad returns to the nest position.
- The graybox now animates a small ant marker along the validated outbound route; collection is applied only after the ant reaches the resource.
- Tapping the nest calculates and animates the return route from the squad's current position; delivery and slot release happen when the return animation completes.
- Input is locked during route animation to prevent overlapping actions.

**Verification: PASS**
- GitHub Actions run **#121** passed: [open run](https://github.com/MaiklLX/Game-ANTS/actions/runs/42013999272).
- Logs explicitly confirm BoardModel, LevelDefinition, ColonyModel, TurnResolver, and Campaign level tests passed; Godot 4.7.2 import and headless main-scene launch passed.
- Visual frame-by-frame inspection and physical-device touch testing remain outstanding.

**Next**
1. Validate the graybox visually in a real Godot editor/device run, especially the 720×1280 layout scaling and touch coordinates.
2. Improve ant animation with a small group of ants, pickup/drop feedback, and a short nest delivery effect.
3. Add a player-visible retry/blocked modal and clear feedback when a different squad must be chosen.
4. Add undo only after action history and animation interruption are deterministic.

**Updated checkpoint phrase:**

`GAME-ANTS — KT-005.1 SQUAD MOVEMENT GREEN. Continue from feat/kt-005-first-playable-levels, draft PR #8. Level schema and LevelLoader provide authored squads/slots; three meadow levels are playable in the portrait graybox. ColonyModel now tracks each squad's current cell, so consecutive pickups route from the previous resource instead of teleporting back to the nest. The UI previews the route, animates the ant marker outbound, applies collection at arrival, then animates the return route when the nest is tapped; delivery/slot release occurs after arrival. Input is locked during animation. Campaign tests verify the one-cell second amber pickup in meadow_003 and nest-position restoration. GitHub Actions run #121 passed all five test suites plus Godot 4.7.2 import and headless main-scene launch. Visual editor/device QA remains outstanding; no APK or public web build. Next: improve ant group/collection/return effects and blocked/retry feedback, then perform real phone visual/touch QA. Keep PRs stacked and draft; never merge to main without owner approval. GitHub Issues only; no external agents.`


### KT-005.2 — Squad presentation and interaction feedback (2026-11-05)
**Branch:** `feat/kt-005-first-playable-levels`  
**Draft PR:** [#8](https://github.com/MaiklLX/Game-ANTS/pull/8)  
**Implementation commit:** `9ea2648f59e857524247f9390d9d8f294ded58fc`  
**Checkpoint commit:** `cffbb1d728fa04942a466c529260d1d444501550`  
**Follow-up cleanup commit:** `efd6739ae21b2fc5a86e729c12ab7a99c378a3be`

**Implemented**
- Replaced the single moving cursor-like marker with a compact three-ant formation that follows the same validated route.
- Added a short expanding ring at the collected resource and at the nest after delivery.
- Added explicit `FIELD CLEARED` and `FIELD BLOCKED` status treatments with distinct panel/accent colors.
- Terminal fields now ignore gameplay taps; only retry or selecting another level remains available.
- Added continuous redraw requests while route and feedback tweens are active, so tweened drawing properties are actually presented frame by frame.

**Verification: PASS**
- GitHub Actions run **#125** passed on the UI implementation commit: https://github.com/MaiklLX/Game-ANTS/actions/runs/42016724874
- GitHub Actions run **#127** passed on the checkpoint commit: https://github.com/MaiklLX/Game-ANTS/actions/runs/42016772487
- Follow-up cleanup resets an in-flight feedback pulse when retrying or switching levels; GitHub Actions run **#131** passed on that latest code commit: https://github.com/MaiklLX/Game-ANTS/actions/runs/42017082813
- Godot 4.7.2 version check and project import passed.
- BoardModel, LevelDefinition, ColonyModel, TurnResolver, and Campaign level tests all passed.
- Main scene launched successfully in headless mode.
- This is still a graybox silhouette, not final pixel art.
- No Godot editor visual inspection, Android APK export, or physical-device touch QA is claimed.

**Next**
1. Run CI and fix any parser or regression failures.
2. Inspect the 720×1280 layout and touch mapping in Godot at representative phone aspect ratios.
3. Improve nest/resource art and add carrying visuals after the basic movement/feedback pass is stable.
4. Keep the campaign deterministic and expand only after the first three levels feel clear.

**Checkpoint phrase:**

`GAME-ANTS — KT-005.2 SQUAD FEEDBACK IMPLEMENTED, CI PENDING. Continue from feat/kt-005-first-playable-levels and draft PR #8. Commit 9ea2648f59e857524247f9390d9d8f294ded58fc changes the graybox UI: three ants travel as a small formation along the validated route; collection and nest delivery trigger expanding feedback rings; completed and blocked fields have distinct status panels; terminal input is limited to retry/level selection. A process redraw loop now keeps tween-driven movement and pulses visible. This remains graybox presentation, not final pixel art. GitHub Actions runs #125 and #127 passed for the UI and checkpoint commits. No editor visual QA, Android APK, or physical-device testing has been performed. Next: verify CI, then inspect phone scaling/touch coordinates and refine nest/resource/carrying visuals. Keep PR #8 draft and stacked; never merge to main without owner approval. Godot 4.7.2-stable remains pinned; GitHub Issues only; no external agents.`


### KT-005.3 — Meadow board visual pass (2026-11-05)
**Branch:** `feat/kt-005-first-playable-levels`
**Implementation commit:** `419e884953bc054eb0affd4204fb867f4f72044d`

**Implemented**
- Added a framed meadow board with alternating ground tones and inset tile surfaces.
- Replaced the flat nest marker with a layered earthen nest entrance.
- Replaced flat resource marks with seed-like bodies, highlights, leaves, and retained color initials for readability.
- Replaced plain blocked tiles with clustered stone silhouettes.
- Core rules, level data, movement paths, and touch coordinate conversion were not changed.

**Verification:** GitHub Actions run **#141** passed on checkpoint commit `3f819a8fa000e8e1bf784fa949b826fbab34c0c6`: Godot 4.7.2 project import, all five test suites, and headless main-scene launch succeeded. This run predates the subsequent carried-seed/ground-texture edits, so those latest edits still require their own CI confirmation. Visual editor/device inspection remains pending.

**Next**
1. Verify the new drawing helpers compile and all five test suites pass.
2. Inspect the board at narrow and tall portrait aspect ratios; tune visual spacing if needed.
3. Add carried-seed feedback and improve squad-card/slot presentation.
4. Keep PR #8 draft and do not merge to `main` without owner approval.


### KT-005.3 — carried-seed and squad feedback extension (2026-11-05)
**Implementation commit:** `68347580bbc8fa1c1232d4becd8d0941d3dd10e7`

- Added a small carried-seed visual beside the lead ant when the selected squad has collected resources.
- Added a capacity meter to squad cards, showing carried resources relative to carrying capacity.
- No core rules, level definitions, pathfinding, or input mapping changed.
- GitHub Actions run #141 passed on the subsequent roadmap checkpoint `3f819a8fa000e8e1bf784fa949b826fbab34c0c6`, confirming the carried-seed and capacity-meter changes plus all five test suites and headless launch.


### KT-005.3 — meadow texture refinement (2026-11-05)
**Implementation commit:** `a9873b15f9cf76c4801382609b9ae963491cd7c5`

- Added restrained, deterministic grass/ground details to meadow tiles, behind gameplay objects. The details vary by cell and stay low-contrast so seeds, nest, rocks, and route markers remain dominant.
- No gameplay rules, level data, pathfinding, animation timing, or touch mapping changed.
- GitHub Actions run **#143** passed on this gameplay commit: Godot 4.7.2 version check, project import, all five test suites, and headless main-scene launch succeeded. Visual editor/device inspection remains outstanding.


### KT-005.4 — first concurrent-squad campaign puzzle (2026-11-05)
**Branch:** `feat/kt-005-first-playable-levels`
**Latest gameplay/UI commit:** `afd74716a8b3e830f4d1e977a9921284300940b4`

- Added `meadow_004`, a four-way campaign step with two resource colors, two simultaneous deployment slots, and a narrow shared passage through a stone barrier.
- Added the fourth field to the campaign selector and updated the level counter.
- Reworked level-picker sizing so all four level buttons and Retry are laid out as one centered group without overlap.
- Added a deterministic integration test that deploys both squads at once, collects their separate matching-color seeds while both slots are occupied, returns both squads, and verifies victory.
- Updated the level format guide with the new field.
- GitHub Actions run **#157** passed on gameplay/UI commit `afd74716a8b3e830f4d1e977a9921284300940b4`; run **#159** also passed on the latest roadmap checkpoint. Both completed Godot 4.7.2 import, all five test suites (including the concurrent-squad integration case), and headless main-scene launch. Editor/device visual QA remains outstanding.
- PR #8 remains Draft and stacked on `feat/kt-004-squad-rules`; no merge to `main`.


### KT-005.5 — three-color slot-pressure puzzle (2026-11-05)
**Branch:** `feat/kt-005-first-playable-levels`
**Status:** Implementation committed; CI PASS on PR run #182.

- Added `meadow_005`, "The Busy Nest": three squad colors (amber, teal, coral), two deployment slots, and four seeds.
- Amber has capacity two and can bring home both upper seeds in one trip; teal and coral each have a single matching seed.
- The level teaches slot scheduling: the third squad cannot deploy until one of the first two returns.
- Added a deterministic integration test that verifies the slot limit, blocked third deployment, slot release after return, and eventual victory.
- Added level 005 to the picker and made the displayed level count derive from the campaign list rather than a hard-coded value.
- No merge to main. Visual editor/device QA remains outstanding.

**Verification: PASS**
- GitHub Actions run **#163** passed on checkpoint commit `b0020306646605ee9d67643dd04305c72e2c53e4`: [open run](https://github.com/MaiklLX/Game-ANTS/actions/runs/42023024966).
- Godot 4.7.2 version check, project import, all five test suites (including the new three-squad slot-pressure integration case), and headless main-scene launch passed.
- This remains headless validation only; editor/device visual QA is not claimed.

**Next:** move into KT-006 interaction clarity and a stronger first-session tutorial.


### KT-006.1 — scalable campaign catalogue (2026-11-05)
**Branch:** `feat/kt-006-scalable-campaign-catalog`
**Base:** `feat/kt-005-first-playable-levels` (stacked after draft PR #8)
**Status:** Implementation committed; CI verification pending.

- Added a root campaign manifest and independent chapter-pack manifests. The first `meadow` pack references the existing five authored levels.
- Added `CampaignCatalog`, which expands the manifest chain, validates each referenced level, and rejects duplicate pack IDs, duplicate level IDs, duplicate file references, missing packs, missing level files, and malformed level data.
- Removed the hard-coded five-level path list from the game screen. Campaign levels now load through the catalog.
- Replaced the five-button-only picker with a five-level paged selector, so the interface can navigate a large catalogue without drawing hundreds of buttons at once.
- Added a dedicated catalog test suite and a CI step for it.
- **Content status:** five real levels exist today. The 300+ target is not being represented as already completed; future chapters will be authored in batches and added as independent packs.
- No merge to `main`; PR #8 remains a dependency. Editor/device visual QA remains outstanding.

**Next:** verify catalog CI, then author and test the first complete 30-level chapter in small reviewed batches.

### KT-006.1 — verification and 300-level production plan
- CI run **#182** passed on catalogue checkpoint `c4135cb162de9ce52b31cfdb7014528fa12f77d7`: [open run](https://github.com/MaiklLX/Game-ANTS/actions/runs/42024460361).
- Godot 4.7.2 import, all five existing test suites, new CampaignCatalog tests, and headless main-scene launch passed.
- Added `docs/CAMPAIGN_CONTENT_PLAN.md`: 10 chapters × 30 levels, chapter pacing, quality gate, append-only content update rules, and a staged production plan.
- Current content remains five playable levels. The first goal is to author and verify the complete 30-level Meadow chapter in reviewed batches.
- PR #9 remains Draft and targets PR #8's feature branch; neither PR is merged to `main`.


### KT-006.1 / Meadow content batch 001–010 — CI checkpoint
- Latest verified implementation/documentation head: ab30a620d1e37ca1fa78b19e887d36b572f14e36.
- GitHub Actions run #204 passed: https://github.com/MaiklLX/Game-ANTS/actions/runs/42025158154.
- Godot 4.7.2 import, BoardModel, LevelDefinition, ColonyModel, TurnResolver, Campaign level integration (levels 001–010), CampaignCatalog tests, and headless main-scene launch all passed.
- The first Meadow chapter now has 10/30 authored levels. Continue with batches of five and preserve a reviewed difficulty curve.
- PR #9 remains Draft and stacked on PR #8. No merge to main.


### Meadow content batch 011–015 — CI PASS
- Added levels 011–015: Split the Shift, Stone Arch, Four Corners, Capacity Choice, and The Last Slot.
- Meadow chapter now contains 15/30 levels; all 15 are included in deterministic campaign integration tests.
- CI run #220 passed: https://github.com/MaiklLX/Game-ANTS/actions/runs/42025359991.
- Godot 4.7.2 import, all six test suites (including campaign catalog and all 15 campaign levels), and headless main-scene launch passed.


### Meadow content batch 016–020 — CI PASS
- Added levels 016–020: Bramble Fork, Long Way Home, Four Colors, Two Slots, Twin Loads, and Meadow Assembly.
- Meadow chapter now contains 20/30 authored levels; all 20 pass the production campaign integration solver.
- GitHub Actions run #240 passed: https://github.com/MaiklLX/Game-ANTS/actions/runs/42025594751.
- Godot 4.7.2 import, all six test suites, and headless main-scene launch passed.


### KT-006.2 — Meadow content batch 021–025 (2026-11-05)
**Branch:** `feat/kt-006-scalable-campaign-catalog`
**Status:** Five new level files committed; CI verification pending.

- Added 021 Narrow Gate, 022 Side Pocket, 023 Three Stops, 024 The Waiting Line, and 025 Forked Harvest.
- Meadow chapter now contains 25/30 authored levels.
- Extended the pack manifest, deterministic campaign integration list, catalog count/order assertions, and level format guide.
- All levels use existing schema-v1 mechanics; no unprototyped mechanics were introduced.
- Next: complete levels 026–030 as the Meadow chapter exam, then review the chapter curve before moving to Root Labyrinth.
- No merge to main; PR #9 remains Draft and stacked on PR #8. Headless CI is the verification gate; editor/device QA remains outstanding.


### KT-006.2 — Meadow chapter complete, levels 001–030 (2026-11-05)
**Branch:** `feat/kt-006-scalable-campaign-catalog`
**Status:** All 30 level files and catalogue/test/documentation updates committed; CI verification pending.

- Completed the first full chapter, The Living Meadow, with 30 authored levels.
- Added 026 Two-Way Detour, 027 Capacity Deadline, 028 Four Openings, 029 The Last Seed Home, and 030 The Meadow Crown.
- Extended the pack manifest and deterministic campaign integration suite through level 030; catalog tests now assert 30 ordered levels and final global index 29.
- The chapter exam uses only existing schema-v1 mechanics. No unimplemented mechanic is assumed.
- Next: run the full Godot 4.7.2 CI suite, review the chapter's difficulty progression, then begin chapter 2 (The Root Labyrinth) with a clear mechanic/level design gate.
- PR #9 remains Draft and stacked on PR #8; no merge to main. Editor/device visual QA remains outstanding.


### KT-007 — Root Labyrinth opening batch 031–035 (2026-11-05)
**Branch:** `feat/kt-006-scalable-campaign-catalog`
**Status:** Five schema-v1 level files and chapter pack added; CI verification pending.

- Added independent chapter pack `campaign/packs/root_labyrinth/pack.json` and appended it after Meadow in the root campaign manifest.
- Added 031 Root Gate, 032 Twin Rootways, 033 The S-Bend, 034 The Root Weave, and 035 The Buried Junction.
- Levels focus on narrow passages, separated openings, forced detours, branching corridors, and multi-entrance routing.
- Extended campaign integration tests and catalogue assertions to 35 ordered levels across two chapters.
- Added route-shape regression tests for non-Manhattan detours and both Root Weave branches.
- Only existing schema-v1 mechanics are used; no new movement controls or unimplemented terrain rules are claimed.
- Next: run CI, inspect any failures, then continue Root Labyrinth 036–040 after reviewing the first batch's path geometry.
- PR #9 remains Draft and stacked on PR #8; no merge to main. Editor/device visual QA remains outstanding.


### KT-007 verification — Root Labyrinth 031–035 (2026-11-05)
- GitHub Actions run #306 passed on `ccbe28ae067966f0b86f9c2bc0543c6910e360a1`: https://github.com/MaiklLX/Game-ANTS/actions/runs/42034141116.
- Godot 4.7.2 import, core and schema tests, colony/squad rules, turn resolver, all 35 campaign level solutions, catalog ordering, route-shape regressions, and headless main-scene launch passed.
- Root Labyrinth now has 5/30 authored levels; next batch is 036–040.


### KT-007 — Root Labyrinth batch 036–040 (2026-11-05)
**Branch:** `feat/kt-006-scalable-campaign-catalog`
**Status:** Five additional level files committed; pack/test/documentation updates committed; CI verification pending.

- Added 036 The Root Ladder, 037 Forked Roots, 038 Parallel Tunnels, 039 The Narrow Seam, and 040 The Root Crown.
- Root Labyrinth now contains 10/30 authored levels; total campaign catalogue is 40/300 target levels across two packs.
- Added the five level references to the Root Labyrinth pack and campaign integration suite; catalog assertions now verify 40 ordered entries and final index 39.
- All resources are reachable using existing deterministic pathfinding; no new movement or terrain mechanic was introduced.
- Next: run full CI, then continue 041–045 if the batch passes.
- PR #9 remains Draft and stacked on PR #8; no merge to main. Editor/device visual QA remains outstanding.


### KT-007 verification — Root Labyrinth 031–040 (2026-11-05)
- GitHub Actions run #324 passed on `a1e1754a44b3e3f5d5aa932be61c35ea5bc3f563`: https://github.com/MaiklLX/Game-ANTS/actions/runs/42034463578.
- Godot 4.7.2 import, core and schema tests, colony/squad rules, turn resolver, all 40 campaign level solutions, catalog ordering, route-shape regressions, and headless main-scene launch passed.
- Root Labyrinth progress: 10/30; total campaign catalogue: 40 authored levels across two packs.
- Next batch: levels 041–045.


### KT-007 — Root Labyrinth batch 041–045 (2026-11-05)
**Branch:** `feat/kt-006-scalable-campaign-catalog`
**Status:** Five additional level files committed; pack/test/documentation updates committed; CI verification pending.

- Added 041 The Split Crossing, 042 The Long Burrow, 043 The Upper and Lower Roots, 044 The Root Divide, and 045 The Hollow Crown.
- Root Labyrinth now contains 15/30 authored levels; total campaign catalogue is 45 levels.
- Extended integration tests and catalog assertions through root_045; added route regression coverage for level 042 and both lanes in level 045.
- All levels use existing schema-v1 mechanics. No new movement or terrain mechanic was introduced.
- Next: run full CI, then continue levels 046–050 if the batch passes.
- PR #9 remains Draft and stacked on PR #8; no merge to main. Editor/device visual QA remains outstanding.


### KT-007 verification — Root Labyrinth 041–045 (2026-11-05)
- GitHub Actions run #345 passed on `ae5bed6a5cd85fd2c76ab8c03ef9689946ede479`: https://github.com/MaiklLX/Game-ANTS/actions/runs/42034766660.
- Godot 4.7.2 import, all core/schema/colony/turn suites, all 45 campaign level solutions, catalog ordering, route-shape regressions, and headless main-scene launch passed.
- Root Labyrinth progress: 15/30; total authored catalogue: 45 levels.
- Next batch: levels 046–050.


### KT-007 — Root Labyrinth batch 046–050 (2026-11-05)
**Branch:** `feat/kt-006-scalable-campaign-catalog`
**Status:** Five additional level files committed; pack/test/documentation updates committed; CI verification pending.

- Added 046 The Stair of Roots, 047 Crossed Passages, 048 The Hidden Pocket, 049 The Deep Turn, and 050 The Labyrinth Heart.
- Root Labyrinth now contains 20/30 authored levels; total campaign catalogue is 50 levels across two packs.
- Extended campaign integration and catalog assertions through root_050; added a route-shape check for the single-entry side pocket in level 048.
- All resources are reachable using existing schema-v1 rules and deterministic pathfinding.
- Next: run full CI, then continue levels 051–055 if the batch passes.
- PR #9 remains Draft and stacked on PR #8; no merge to main. Editor/device visual QA remains outstanding.


### KT-007 verification — Root Labyrinth 046–050 (2026-11-05)
- GitHub Actions run #364 passed on `dccaea00798d345e2c52ca8f44834cc024666ee8`: https://github.com/MaiklLX/Game-ANTS/actions/runs/42035050710.
- Godot 4.7.2 import, core/schema/colony/turn suites, all 50 campaign level solutions, catalog ordering, route-shape regressions, and headless main-scene launch passed.
- Root Labyrinth progress: 20/30; total authored catalogue: 50 levels across two chapters.
- Next batch: levels 051–055.


### KT-007 — Root Labyrinth batch 051–055 (2026-11-05)
**Branch:** `feat/kt-006-scalable-campaign-catalog`
**Status:** Five authored schema-v1 levels added; integration/catalog tests and chapter documentation extended. CI verification pending.

- Added 051 The Bent Gate, 052 Twin Root Mouths, 053 The Turning Fork, 054 The Middle Passage, and 055 The Root Labyrinth Trial.
- Root Labyrinth now contains 25/30 authored levels; total campaign catalogue contains 55 levels across two packs.
- Added a route-shape regression for the forced low crossing in level 051.
- Every level is included in the production-rule campaign solver; no unprototyped mechanic was added.
- Next: run full CI, review difficulty/readability, then continue levels 056–060 if the batch passes.
- PR #9 remains Draft and stacked on PR #8; no merge to main. Editor/device visual QA remains outstanding.


### KT-007 verification — Root Labyrinth 051–055 (2026-11-05)
- GitHub Actions run #381 passed on `327e90c0760c95d3ff47d96094b571d8e426fe08`: https://github.com/MaiklLX/Game-ANTS/actions/runs/42036509316.
- Godot 4.7.2 version check and project import passed; all deterministic core, level validation, colony/squad, turn resolver, campaign level, and campaign catalogue tests passed; the main scene launched headlessly.
- Root Labyrinth progress: 25/30; total authored catalogue: 55 levels across two chapter packs.
- Next batch: levels 056–060, then review the completed chapter before starting The Amber Orchard.
- No editor visual QA, Android APK export, physical-device testing, or public web build is claimed. PR #9 remains Draft and unmerged.


### KT-007.5 — Root Labyrinth 056–060 (2026-11-05)
**Branch:** `feat/kt-006-scalable-campaign-catalog`
**Status:** Five final chapter levels added; integration/catalog tests and chapter documentation extended. CI verification pending.

- Added 056 The Switchback Gate, 057 Three Root Mouths, 058 The Heartwood Pocket, 059 The Double Bend, and 060 The Labyrinth Unbound.
- The Root Labyrinth is now complete: 30/30 levels. Total authored catalogue: 60/300 across two chapters.
- Added a long-route regression for level 056 and four-route reachability checks for the level 060 finale.
- All five levels use schema v1 and existing production mechanics only.
- Next: full CI and a chapter-level content review, then begin The Amber Orchard (061–090).
- PR #9 remains Draft and stacked on PR #8; no merge to main. Editor/device visual QA remains outstanding.



### KT-008 — Root Labyrinth design audit (2026-11-05)
- Reviewed all 30 chapter level files, pack manifest, BoardModel/TurnResolver behavior, campaign integration solver, and route-shape regression coverage.
- Confirmed production-rule solvability coverage for all 60 authored levels; CI run #406 passed on head `b9b10645b56f3ad29162d674b8af4e632b16ea4f`: https://github.com/MaiklLX/Game-ANTS/actions/runs/42037763989.
- Design audit found a repeated obstacle/resource footprint across levels 037, 038, and 041, plus related barrier-layout families around 047/057/059 and four-resource crown/finale layouts.
- Current campaign solver proves deterministic collection/return and reachability, not strategic variety, route-order decisions, difficulty balance, or mobile readability.
- Chapter 2 is **30/30 authored and automated-validation passed**, but **not yet design-signed-off**. Targeted geometry revision, map-signature regression tests, and manual portrait Editor QA remain open.
- Full audit: `docs/ROOT_LABYRINTH_AUDIT.md`. Chapter 3 may proceed in reviewed five-level batches; retain a separate revision task for the Root Labyrinth duplication cluster.
- PR #9 remains Draft and stacked on PR #8. No merge to main. No editor/device QA, APK, or public web build is claimed.



### KT-008.1 — Amber Orchard opening batch 061–065 (2026-11-05)
- Added the third chapter pack `amber_orchard` and appended it after Root Labyrinth in the root campaign manifest.
- Added 061 First Golden Bough, 062 Twin Canopies, 063 The Long Golden Cluster, 064 The Middle Crossing, and 065 The Balanced Harvest.
- The batch focuses on load planning and squad specialization using existing schema-v1 capacity, color, slot, obstacle, and deterministic path rules only.
- Campaign integration tests now include levels 061–065; catalogue assertions expect 65 ordered levels and verify chapter 3 identity and global indices.
- Root Labyrinth design audit remains open as a separate revision task; no claim of chapter 2 design sign-off or manual visual QA.
- CI run #415 passed on corrected code head `2d6e25c2e0320346397da087082007c50bbad920`: https://github.com/MaiklLX/Game-ANTS/actions/runs/42038997667. Godot 4.7.2 import, all deterministic/core/schema/colony/turn tests, all 65 campaign level solutions, catalogue validation, and headless main-scene launch passed.
- PR #9 remains Draft, stacked on PR #8; no merge to main.


### KT-008.2 — Version 1.0 campaign scope approved (2026-11-05)
**Decision:** Version 1.0 targets 100 quality-checked levels. The 300+ level ambition remains the long-term campaign vision for post-launch updates.

- Approved launch structure: The Living Meadow 001–030, The Root Labyrinth 031–060, The Amber Orchard 061–090, and a compact 10-level conclusion 091–100.
- Current content at the KT-008.2 decision: 65/100 authored; 35 levels remained.
- The short finale is a release-structure decision; its detailed theme and levels remain subject to design review. No unproven mechanics are required for v1.
- Release readiness is broader than level count: variety, difficulty balance, onboarding, save/progress reliability, portrait mobile readability, performance, and device QA remain required.
- CI run #417 passed on the prior code/documentation head `1e726ab87bb514f8c22891e87e96e1ea2030722c`: https://github.com/MaiklLX/Game-ANTS/actions/runs/42039105315. This verifies the existing 65-level state, not the new documentation-only scope decision.
- Next: continue Amber Orchard in five-level batches, starting at 066–070, while retaining Root Labyrinth's separate design-revision task.
- PR #9 remains Draft, open, stacked on PR #8, and unmerged. No editor/device visual QA, APK, or public web build is claimed.


### KT-008.3 — Amber Orchard batch 066–070 (2026-11-05)
- Added 066 The Fork of Gold, 067 The Hollow Canopy, 068 Three Golden Steps, 069 The Four Boughs, and 070 The Orchard Weave.
- The batch varies central-crossing, heartwood-island, staggered-branch, divided-trunk, and multi-color slot-pressure layouts while staying within schema v1.
- Registered all five levels in the Amber Orchard pack; campaign level tests include all 70 level files and catalogue tests assert stable order through global index 69.
- Amber Orchard progress: 10/30. Version 1.0 campaign progress: 70/100; 30 levels remain.
- CI #451 passed for the 70-level checkpoint; the follow-up batch 071–075 is now registered and awaits CI. No editor/device visual QA or APK is claimed.
- Root Labyrinth design revisions remain a separate open task. PR #9 remains Draft, stacked, and unmerged.

- Follow-up after KT-008.2: Amber Orchard batch 066–070 is now authored and registered. Current campaign content is 70/100; 30 levels remain. CI run #444 passed on corrected code head `cb0033dce2644d3e7623f1d606f5f54cef32fc14`: https://github.com/MaiklLX/Game-ANTS/actions/runs/42040921577. Godot 4.7.2 import, all core/schema/colony/turn tests, all 70 campaign level tests, and campaign catalogue tests passed. Documentation-only CI #449 is in progress on the latest head.

- Latest verification: CI run #451 passed on current branch head b87ae97d35604aebd113fce22ad5d265a08467c0: https://github.com/MaiklLX/Game-ANTS/actions/runs/42041100657. Godot 4.7.2 import, every deterministic/core/schema/colony/turn suite, all 70 campaign levels, campaign catalogue checks, and headless main-scene launch passed.


### KT-008.4 — Amber Orchard batch 071–075 (2026-11-05)
- Added The Split Crown (071), The Sunken Branch (072), The Amber Spiral (073), The Crosswind Grove (074), and The Golden Canopy Trial (075).
- All five levels use existing schema-v1 mechanics. Added to the Amber Orchard pack; deterministic campaign test list now covers 75 level files; catalogue assertions verify 75 entries and stable final index 74.
- Campaign progress: **75/100 authored; 25 remain**. Amber Orchard: 15/30.
- CI #474 passed on corrected 75-level code head `614804d513df89dee6b18620e6f4efe08653ad22`: https://github.com/MaiklLX/Game-ANTS/actions/runs/42042309984. Godot 4.7.2 import, all campaign-level integration tests (75 levels), catalogue tests, and headless main-scene launch passed. No editor/device visual QA or APK is claimed.
- Next batch: Amber Orchard 076–080. Root Labyrinth design revisions remain separate.

- CI #474 also confirms the level 074 route correction; all test suites passed. Documentation-only CI #475 is still running on the same 75-level state.


### KT-008.5 — Amber Orchard batch 076–080 (2026-11-05)
- Added The Bramble Window (076), The Falling Leaves (077), The Four Hidden Boughs (078), The Golden Switchback (079), and The Orchard Crossroads (080).
- All five use existing schema-v1 mechanics; static checks passed for coordinate uniqueness, resource reachability, and matching squad colors.
- Registered all five in the Amber Orchard pack. Campaign integration tests now include 80 level files; catalogue tests assert 80 entries and stable global index 79.
- Campaign progress: **80/100 authored; 20 remain**. Amber Orchard: 20/30.
- CI is pending for this batch. No Editor/device visual QA or APK is claimed.
- Next: Amber Orchard 081–085. Root Labyrinth design revisions remain separate.
