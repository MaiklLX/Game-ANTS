# ANTWORKS — campaign content plan

## Target

- **Launch campaign:** 300 hand-authored, quality-checked levels.
- **Structure:** 10 chapters × 30 levels.
- **Expansion:** additional chapter packs can be appended through the root campaign manifest in later updates.
- **Current reality:** 5 playable prototype levels in the Meadow pack. The 300-level target is planned content, not yet delivered.

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
| 031–060 | The Root Labyrinth | Narrow corridors, alternate routes, route order, and spatial planning. |
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

Build the first complete 30-level Meadow chapter in reviewed batches, not one huge unreviewed dump. Each batch should add a small group of levels, solution tests, and a short difficulty review. Only after the full chapter has a coherent curve should production move to chapter 2.
