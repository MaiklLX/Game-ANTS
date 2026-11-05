# ANTWORKS — campaign content plan

## Target

- **Launch campaign:** 300 hand-authored, quality-checked levels.
- **Structure:** 10 chapters × 30 levels.
- **Expansion:** additional chapter packs can be appended through the root campaign manifest in later updates.
- **Current reality:** 30 authored levels in the Meadow pack; the remaining nine chapters are still planned content.

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
| 091–120 | The Riverbank | Candidate water/bridge terrain mechanic; only after a dedicated prototype. |
| 121–150 | The Night Garden | Candidate visibility or light-based puzzle mechanic; only if readable on small screens. |
| 151–180 | The Stoneworks | Candidate gates and switches; no level may rely on them before schema and tests exist. |
| 181–210 | The Pheromone Fields | Candidate pheromone-route mechanic; prototype and compare against baseline puzzles first. |
| 211–240 | The Ancient Nest | Multi-route coordination and candidate additional nest/colony structures. |
| 241–270 | The Wildwood | Multi-mechanic combinations and longer strategic sequences. |
| 271–300 | The Colony Heart | Final mastery chapter: fair, readable, high-skill puzzles using the proven mechanics. |

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
- The chapter is 15/30 authored; its remaining 15 levels will deepen corridor reading and expedition ordering without relying on unimplemented mechanics.


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
- 045 The Hollow Crown is the 15-level chapter checkpoint, with four colors and two separated lanes around central heartwood.
- Automated tests assert the long detour in 042 and reachability of both lanes in 045. All use schema v1.
