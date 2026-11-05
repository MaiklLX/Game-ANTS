# ANTWORKS — campaign content plan

## Target

- **Version 1.0 launch campaign:** 100 hand-authored, quality-checked levels.
- **Version 1.0 structure:** three full chapters of 30 levels (001–090), followed by a 10-level concluding chapter (091–100).
- **Long-term campaign vision:** 300+ levels, expanded gradually through later updates. The original ten-chapter/300-level ambition remains the long-term roadmap, not a blocker for version 1.0.
- **Current reality:** 100 of the 100 launch levels are authored: The Living Meadow 001–030 (30/30), The Root Labyrinth 031–060 (30/30; design revisions remain open), and The Amber Orchard 061–090 (30/30), and The Colony Heart: First Dawn 091–100 (10/10). **All 100 launch levels are authored** to reach the version 1.0 content target.
- **Release principle:** reaching 100 is a content milestone, not automatic release approval. The launch gate also includes level variety and balance review, onboarding, readable portrait UI, save/progress reliability, performance, and mobile playtesting.

## Chapter rhythm

Each 30-level chapter follows a deliberate learning curve:

1. **Levels 1–5 — introduce:** one idea at a time, safe experimentation, short solutions.
2. **Levels 6–12 — reinforce:** vary board geometry and resource placement without adding hidden rules.
3. **Levels 13–20 — combine:** require two or more already-taught decisions in one puzzle.
4. **Levels 21–27 — challenge:** tighter capacity, slot pressure, branching routes, and less forgiving layouts.
5. **Levels 28–30 — chapter exam:** memorable multi-step puzzles that use the chapter's full vocabulary.

This is a pacing guide, not a requirement to make every level harder than the previous one. Rest levels and clever short puzzles are useful.

## Planned chapter themes

Themes and mechanics below are design directions. Any mechanic not supported by the current rules must be prototyped, tested, and added to the level schema before levels depend on it.

| Range | Chapter | Main design focus |
|---|---|---|
| 001–030 | The Living Meadow | Learn squad colors, deployment slots, carrying capacity, nest returns, and obstacle routing. |
| 031–060 | The Root Labyrinth | Narrow corridors, alternate openings, forced detours, and spatial planning. |
| 061–090 | The Amber Orchard | Efficient multi-resource trips, load planning, and squad specialization. |
| 091–100 | The Colony Heart: First Dawn (proposed launch finale) | A compact 10-level conclusion using proven launch mechanics. |
| 101–130 | The Riverbank (post-launch) | Candidate water/bridge terrain mechanic; only after a dedicated prototype. |
| 131–160 | The Night Garden (post-launch) | Candidate visibility or light-based puzzle mechanic; only if readable on small screens. |
| 161–190 | The Stoneworks (post-launch) | Candidate gates and switches; no level may rely on them before schema and tests exist. |
| 191–220 | The Pheromone Fields (post-launch) | Candidate pheromone-route mechanic; prototype and compare against baseline puzzles first. |
| 221–250 | The Ancient Nest (post-launch) | Multi-route coordination and candidate additional nest/colony structures. |
| 251–280 | The Wildwood (post-launch) | Multi-mechanic combinations and longer strategic sequences. |
| 281–300 | The Colony Heart: Mastery (post-launch) | Final mastery chapter using proven mechanics. |

## Level quality gate

Every level must pass all of the following before it enters a release pack:

- Valid JSON and supported schema version.
- Stable unique level ID and one manifest reference.
- Clear title and short objective that do not give away the whole solution.
- At least one deterministic solution using the production rules.
- No accidental soft-lock; blocked states must be intentional and explained by the puzzle.
- A distinct decision from nearby levels; avoid simple coordinate swaps as fake variety.
- Manual design review for difficulty, clarity, and phone-screen readability.
- Regression test coverage for new mechanics and representative campaign solutions.

Automated solvability is necessary but not sufficient. A level that is technically solvable can still be boring, opaque, or repetitive.

## Content update rules

- Keep each chapter in its own pack manifest.
- Add new packs by appending their manifest reference; do not rewrite unrelated chapters.
- Keep released level IDs stable forever. Never reuse an ID for a different puzzle.
- Preserve released level order. New levels are appended as new packs or at the end of a not-yet-released chapter.
- Save player progress by stable level ID, not by array index or page number.
- If a released puzzle must be corrected, document the change and retain compatibility with existing progress.
- Version the campaign and pack schemas when structural changes are required.

## Production batches

Build the first complete 30-level Meadow chapter in reviewed batches, not one huge unreviewed dump. The first Meadow chapter now covers levels 001–030. Review its complete difficulty curve before starting chapter 2. Each batch should add a small group of levels, solution tests, and a short difficulty review. Only after the full chapter has a coherent curve should production move to chapter 2.


## KT-007 — Root Labyrinth opening batch (031–035)

- Chapter 2 has its own pack manifest at `campaign/packs/root_labyrinth/pack.json`, appended after Meadow in the root campaign manifest.
- The opening five levels introduce narrow passages, separated upper/lower openings, staggered S-bends, split branches, and a multi-entrance junction.
- This batch deliberately uses only existing schema-v1 rules: static obstacles, colored resources, squads, carrying capacity, and deployment slots. No new movement rule or manual path-drawing control is implied.
- Automated route-shape tests assert genuine detours in selected levels and reachability of both branches in Root Weave.
- The chapter is 20/30 authored; its remaining 10 levels will deepen corridor reading and expedition ordering without relying on unimplemented mechanics.


### Root Labyrinth production batch 036–040
- 036 The Root Ladder introduces a capacity-two collection along a constrained upper corridor.
- 037 Forked Roots adds a three-color choice around a fork.
- 038 Parallel Tunnels tests two active squads using separated openings while another waits for a slot.
- 039 The Narrow Seam focuses on approaching a single crossing through a horizontal barrier.
- 040 The Root Crown is the first ten-level checkpoint, combining four resource colors and two corridors around a central obstacle mass.
- All puzzles remain schema v1 and are checked by the production campaign solver.


### Root Labyrinth production batch 041–045
- 041 The Split Crossing combines two narrow openings with three resource colors and two deployment slots.
- 042 The Long Burrow adds a capacity-two load behind a pair of forced turns.
- 043 The Upper and Lower Roots teaches channel reading around a horizontal obstacle band.
- 044 The Root Divide uses upper/lower entries to split access across the board.
- 045 The Hollow Crown is the 15-level chapter checkpoint: a coral cache sits inside a central hollow behind one upper notch, while four squads rotate through two deployment slots.
- Automated tests assert the long detour in 042 and reachability of both lanes in 045. All use schema v1.


### Root Labyrinth production batch 046–050
- 046 The Stair of Roots introduces a staggered upper-then-lower crossing.
- 047 Crossed Passages combines three colors with two corridor gates and slot pressure.
- 048 The Hidden Pocket places a resource in a side chamber with a single entrance; route tests assert the longer approach.
- 049 The Deep Turn reinforces central detours and upper/lower chamber access.
- 050 The Labyrinth Heart is the 20-level checkpoint, combining four colors and two winding passages.
- All levels use schema v1 and are solved through the production campaign integration test.


### Root Labyrinth production batch 051–055
- 051 The Bent Gate makes a low crossing mandatory before an upper-corner harvest.
- 052 Twin Root Mouths separates access to upper and lower chambers into distinct entrances.
- 053 The Turning Fork alternates the side of travel across two staggered barriers.
- 054 The Middle Passage combines three resource colors behind one crossing and two deployment slots.
- 055 The Root Labyrinth Trial is the 25-level checkpoint, combining four colors, slot pressure, and alternating openings.
- All five levels use schema v1 and are covered by the deterministic campaign solver; no new mechanic is introduced.


### Root Labyrinth production batch 056–060 — chapter complete
- 056 The Switchback Gate uses a low first opening and an upper-side second entrance.
- 057 Three Root Mouths combines three harvest colors with alternating corridor openings.
- 058 The Heartwood Pocket places a resource inside a ring with one open access notch.
- 059 The Double Bend forces two direction changes across staggered barriers.
- 060 The Labyrinth Unbound is the 30-level chapter finale, with four colored harvest routes and a long eastern lane.
- All levels use schema v1. The integration solver checks every resource collection and return; route tests assert the long switchback and all four finale routes.
- Chapter 2 is complete at 30/30. Review the chapter's full difficulty curve before beginning The Amber Orchard (061–090).


## Root Labyrinth design audit — 2026-11-05

- The chapter is 30/30 authored and passes deterministic production-rule campaign validation, but this is not equivalent to design sign-off.
- Audit found an identical obstacle/resource footprint across levels 037, 038, and 041; the roster/colors change but the spatial puzzle is effectively repeated.
- Levels 047, 057, and 059 also form a related alternating-wall motif; 035, 040, 045, 050, 055, and 060 share related multi-color central/corridor structures. These need distinct decisions, not cosmetic changes.
- The campaign integration solver proves deterministic solvability, color matching, capacity use, and returns. It does not prove strategic order choices, uniqueness, difficulty balance, or mobile readability.
- Required before release sign-off: redesign at least one of 037/038/041; review the 047/057/059 family; add map-signature regression coverage; perform manual Godot Editor portrait playthrough; rerun CI.
- Full findings: `docs/ROOT_LABYRINTH_AUDIT.md`.
- Chapter 3 production may begin in five-level batches, but chapter 2's targeted revision remains an explicit open task.


### Amber Orchard production batch 061–065
- 61 First Golden Bough: A two-seed amber load waits beyond the low crossing; bring it home before the teal scout.
- 62 Twin Canopies: Two carriers can each fill a matching load, but the upper and lower boughs must be planned separately.
- 63 The Long Golden Cluster: Three amber seeds share one connected branch; use the carrier's full capacity in a single expedition.
- 64 The Middle Crossing: Upper and lower loads meet at one narrow crossing; decide which carrier should occupy the open slot first.
- 65 The Balanced Harvest: Four colors and two full loads compete for two field slots; plan the order that keeps every carrier useful.
- All five use schema-v1 mechanics only; the deterministic production-rule solver covers collection and return.


## Version 1.0 scope decision — 2026-11-05

The approved first-release target is **100 quality-checked levels**, not 300. The 300+ campaign remains the long-term product vision and will grow through updates after launch.

- Launch chapters: Meadow 001–030, Root Labyrinth 031–060, Amber Orchard 061–090, and a compact finale 091–100.
- Current content: 65/100 authored; 35 levels remain.
- The 10-level finale is the agreed release structure; its exact theme and level designs remain subject to content review.
- Do not add unprototyped mechanics merely to make the finale feel different. Version 1.0 should use proven, readable rules.
- Do not treat 100 authored levels as sufficient by themselves: release also requires campaign variety, difficulty/balance review, onboarding, save/progress reliability, portrait mobile QA, and performance checks.
- Chapters beyond level 100 are post-launch expansion content; the 300-level vision is not cancelled.


### Amber Orchard production batch 066–070
- 066 The Fork of Gold: one central crossing connects a two-seed amber bough and a separate teal harvest.
- 067 The Hollow Canopy: a central heartwood island creates upper and lower loops for two full-load carriers.
- 068 Three Golden Steps: a capacity-three amber squad clears a staggered three-seed branch in one expedition.
- 069 The Four Boughs: four colors sit on opposite sides of a divided trunk, with only two deployment slots.
- 070 The Orchard Weave: a capacity-three amber cluster and paired teal harvest share the field with two single-seed scouts.
- All five levels use schema-v1 mechanics only. Each resource is reachable under the current board rules; campaign integration tests cover deterministic collection and return.
- Amber Orchard progress: 10/30. Total catalogue: 70/100 for version 1.0; 30 levels remain.


### Amber Orchard production batch 071–075
- 071 The Split Crown: a single opening through a vertical trunk separates four colored harvest points; two slots force squad rotation.
- 072 The Sunken Branch: a horizontal cross-trunk and upper offset roots create a winding upper approach and a lower resource pocket.
- 073 The Amber Spiral: a capacity-three amber expedition follows a curled route around heartwood, with a separate teal pickup.
- 074 The Crosswind Grove: staggered roots divide the board into offset pockets for a paired amber load and two single-color trips.
- 075 The Golden Canopy Trial: two paired harvests and two lone seeds are coordinated across three deployment slots.
- All five use schema-v1 rules only. Campaign integration tests validate each resource pickup and delivery with the authored roster.
- Amber Orchard progress: 15/30. Total catalogue: 75/100 for version 1.0; 25 levels remain.


### Amber Orchard production batch 076–080
- 076 The Bramble Window: a low opening and a second offset root wall turn a paired amber harvest into a long return loop.
- 077 The Falling Leaves: a descending line of roots divides two paired harvests for capacity-two carriers.
- 078 The Four Hidden Boughs: four colors sit behind an L-shaped root screen; two field slots require careful squad rotation.
- 079 The Golden Switchback: a capacity-three amber squad follows a staggered route around a root shelf, with a separate teal pickup.
- 080 The Orchard Crossroads: two paired loads and two single seeds converge around a central crossing with three deployment slots.
- All five use schema-v1 rules. Static checks confirm unique tile coordinates, reachable resources, and matching squad colors; campaign integration tests verify collection and return.
- Amber Orchard progress: 20/30. Total catalogue: 80/100 for version 1.0; 20 levels remain.


### Amber Orchard production batch 081–085
- 081 The Bent Orchard: a squared root bend separates a paired amber harvest from a coral pocket and a nearby teal seed.
- 082 The Canopy Steps: two paired harvests sit on opposite sides of a rising root stair.
- 083 The Hidden Sun: the coral seed sits in a sheltered central lane between two root shelves, with the other colors in outer boughs.
- 084 The Compass Branches: two separated openings connect four outer pockets; one deployment slot forces the squads to alternate upper and lower branches.
- 085 The Orchard Keeper's Trial: a capacity-three amber branch, paired teal load, and two lone seeds test all four squad roles across three slots.
- All five use schema-v1 rules. Static checks confirm unique tile coordinates, reachable resources, and matching squad colors; campaign integration tests verify collection and return.
- Amber Orchard progress: 25/30. Total catalogue: 85/100 for version 1.0; 15 levels remain.


### Amber Orchard production batch 086–090 — chapter complete
- 086 The Amber Gatehouse: a narrow upper gate separates the amber pair from two near-side single seeds.
- 087 The Orchard's Last Shade: a capacity-three violet expedition follows an outer branch, with a separate teal pickup.
- 088 The Three Canopies: three paired harvests must be completed with two deployment slots.
- 089 The Orchard's Long Walk: four colors sit behind a staggered root maze and require slot rotation.
- 090 The Heart of Amber: chapter finale combining two full loads, three single seeds, and three deployment slots.
- All five use schema-v1 rules. Static checks confirm unique tile coordinates, reachable resources, and matching squad colors; campaign integration tests verify collection and return.
- Amber Orchard is now complete: 30/30. Total catalogue: 90/100 for version 1.0; 10 levels remain for the compact launch finale.


## Version 1.0 finale — The Colony Heart: First Dawn (091–100)

This is a provisional chapter title; the 10-level finale scope is approved, while the final naming and presentation can still be refined during content review. The finale deliberately introduces no new mechanics: it recombines the proven squad colors, carrying capacities, deployment slots, and obstacle routing.

- 091 First Light at the Nest: a paired amber harvest beyond a narrow gate and a near-side teal pickup.
- 092 The First Ring: two paired harvests arranged above and below a central clearing.
- 093 Three Seeds, Three Paths: a capacity-three amber load alongside teal and coral scouts.
- 094 The Four Fires: four colors on opposite corners, managed with two deployment slots.
- 095 The Shared Passage: two paired loads share one narrow gate and one active slot.
- 096 The Rooted Crown: two full loads and a single seed circle a broken root crown.
- 097 The Long Return: a capacity-three violet expedition with amber and teal side pickups.
- 098 Four Branches, One Nest: four single-seed squads and two deployment slots.
- 099 The Last Crossing: two paired loads and two lone seeds share a central bottleneck.
- 100 The Colony Heart: final four-color trial with eight seeds and three deployment slots.

All 10 levels are registered in the fourth chapter pack. Static checks and campaign integration tests cover all resource routes, squad-color matches, collection, and return. **Content count: 100/100.** This is not a release sign-off: balance, variety, onboarding, save/progress, portrait mobile QA, performance, and device testing remain mandatory.
