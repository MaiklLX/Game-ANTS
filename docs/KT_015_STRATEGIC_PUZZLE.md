# KT-015 — Strategic Puzzle: Expedition Planning

Status: design contract and implementation plan  
Base checkpoint: `5826660c0cf32f6d2361904a88f8e65883494b9a`  
Working branch: `feat/kt-015-strategic-puzzle`  
Main remains untouched. PR #9 remains Draft and unmerged.

## Product goal

Turn Game-ANTS from automatic resource collection into a readable, deterministic planning puzzle. The player must decide which squad to deploy, which resource to target, when to return, and how to coordinate multiple expeditions within a finite day.

The game remains calm and turn-based. No real-time countdown and no reflex requirement.

## Core turn contract

1. The player may select squads and issue or revise orders during the planning phase.
2. A squad order is explicit: deploy/activate, move to a chosen resource, or return to the nest. The game never chooses a resource or next destination automatically.
3. Before committing a turn, show the next movement/action for each active squad and the shared remaining-day budget.
4. On **Next Turn**, every active squad with a valid order advances by at most one path cell. Squads without orders wait.
5. Reaching a resource collects it only when the squad has capacity and matching color; collection is resolved deterministically and the squad then waits for a new order.
6. A return order moves the squad one cell per turn toward the nest. Delivery occurs only when it reaches the nest.
7. One global day point is consumed per committed turn, regardless of how many squads moved. The player can plan several squads in parallel, so coordination is valuable.
8. If the objective is delivered before the day budget reaches zero, the level is won. If the budget reaches zero first, the day ends and the level is lost.
9. No automatic re-dispatch, no automatic return, and no background movement during planning.

## Why this closes the one-squad shuttle exploit

Every movement step and return step consumes the same finite global day. Repeated trips are possible only if the remaining day budget allows them. Parallel squads can make progress in the same committed turn, but deployment slots, matching colors, carrying capacity, route lengths, and the day limit constrain the plan.

Do not add arbitrary random penalties. Any future fatigue mechanic must be visible, deterministic, and taught before it is required.

## First playable scope

- Explicit target selection and route preview.
- Shared turn/day budget with a clear Next Turn action.
- One-cell-per-turn movement for all ordered squads.
- Resource collection and nest delivery integrated into turn resolution.
- Clear win/loss state and remaining-turn display.
- No fatigue, weather, dynamic gates, or new squad classes in the first slice.
- Keep existing art, board style, campaign catalogue, and stable level IDs.

## Level progression

The five-level arrows are catalogue pagination, not campaign progression. Preserve page size five and make the page indicator explicit. Do not silently jump the selected level by five. Sequential unlock gating is a separate policy decision; for this milestone, do not lock existing levels without owner approval. Add tests proving page navigation changes only the visible catalogue slice and that the selected level ID remains stable.

## Android display requirement

The previous immersive-mode settings and runtime fullscreen call did not resolve the owner's device report. Diagnose the exported Android display behavior rather than repeating the same flag. Verify Godot 4.7.2 preset/manifest settings and distinguish visible system bars from unused letterboxed viewport space. Keep portrait orientation and responsive canvas behavior.

## Validation contract

- Unit tests for day budget, one-cell simultaneous squad movement, explicit orders, collection, delivery, no auto-dispatch, and deterministic resolution.
- Regression tests for insufficient turns, full capacity, wrong-color resources, blocked paths, and two squads competing for a cell.
- Campaign solver/audit must still load all 100 existing levels; no authored level should be silently changed by the new runtime rules.
- Add a small, deliberately authored strategic tutorial sequence (initially levels 001–010 only after runtime mechanics are stable). Do not bulk-rebalance all 100 levels before the new rules are proven.
- CI must pass import, core tests, all 100 campaign tests, campaign audit, and headless main-scene launch.
- APK/device and editor visual QA are separate gates; do not claim them from headless CI.

## Implementation sequence

### KT-015.1 — turn engine
Introduce a pure turn-state/resolution layer and tests before connecting visuals. Define deterministic collision handling and order cancellation semantics.

### KT-015.2 — player command flow
Remove automatic dispatch. Add squad selection, target/return orders, route previews, and a clear Next Turn control.

### KT-015.3 — HUD and feedback
Show remaining day, squad status, cargo, and predicted next step. Preserve the current visual identity and mobile layout.

### KT-015.4 — campaign and progression regression
Clarify five-level pagination, preserve stable level IDs and save data, and test the reported five-level jump.

### KT-015.5 — Android display diagnosis
Inspect exported manifest/theme/window behavior and viewport sizing; correct only the verified cause.

### KT-015.6 — first strategic levels and QA
Create/adjust a small onboarding batch, validate solvability and meaningful choices, then build an APK for owner testing.

## Design guardrails

- No hidden costs or surprise penalties.
- Every level must have a verified solution under the production turn rules.
- Easy to understand on a phone; hard to optimize perfectly.
- The player plans; ants execute. Animation communicates state, not substitutes for decisions.
- Preserve main, PR #9, and existing checkpoints. No merge without explicit approval.
