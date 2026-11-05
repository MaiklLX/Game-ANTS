# Level data format — schema v1

Campaign levels are stored as UTF-8 JSON files and discovered through a manifest chain. The file is data only; rendering and animation must not be embedded in it.

## Scalable campaign layout

- `campaign/campaign_manifest.json` is the root index. It lists chapter-pack manifest files in campaign order.
- Each `campaign/packs/<chapter>/pack.json` defines one chapter and lists its level IDs and JSON file paths in play order.
- Each level JSON remains an independent file under `levels/` (or a future content directory).
- `CampaignCatalog` expands the manifest chain, validates each pack and level, rejects duplicate chapter IDs, level IDs, and file references, and returns a flat ordered catalogue to the game.
- The UI shows five levels at a time and pages through the catalogue. The game no longer has a hard-coded list of level paths.

The current campaign contains 35 authored levels across two chapter packs: Meadow 001–030 and Root Labyrinth 031–035. The architecture has no five-level or 300-level cap: the 300-level target is a content-production goal, not a hard-coded engine limit.

### Adding a future chapter

1. Create a new chapter directory and its `pack.json`.
2. Add the new level JSON files and list them in the pack manifest in intended play order.
3. Add one pack reference to `campaign/campaign_manifest.json`.
4. Run the campaign catalog and campaign solution tests.
5. Review the chapter's learning curve and verify every level has a deterministic solution before release.

Use stable IDs; never recycle a released level ID. Add new chapters as separate packs so updates can append content without rewriting existing level data.

## Examples

- [level_001.json](../levels/level_001.json) — first collection and return.
- [level_002.json](../levels/level_002.json) — two resource colors with one deployment slot.
- [level_003.json](../levels/level_003.json) — two amber seeds, one teal seed, and capacity planning.
- [level_004.json](../levels/level_004.json) — two simultaneous squads, two deployment slots, and a narrow shared passage.
- [level_005.json](../levels/level_005.json) — three squad colors competing for two deployment slots, with a capacity-two amber haul.
- [level_006.json](../levels/level_006.json) — capacity-one repeat trips around a pebble bend.
- [level_007.json](../levels/level_007.json) — three colors sharing one deployment slot.
- [level_008.json](../levels/level_008.json) — two active slots, a waiting squad, and a crosswind obstacle layout.
- [level_009.json](../levels/level_009.json) — a three-seed harvest split across capacity-limited trips.
- [level_010.json](../levels/level_010.json) — violet multi-pickup routing alongside an amber delivery.
- [level_011.json](../levels/level_011.json) — a capacity-two amber team working alongside two smaller squads.
- [level_012.json](../levels/level_012.json) — one narrow crossing through a stone wall.
- [level_013.json](../levels/level_013.json) — four resource colors placed around a blocked center.
- [level_014.json](../levels/level_014.json) — compare a full two-seed load with two single-seed trips.
- [level_015.json](../levels/level_015.json) — four squads competing for three deployment slots.
- [level_016.json](../levels/level_016.json) — a long lower crossing around a bramble wall.
- [level_017.json](../levels/level_017.json) — three colors and intersecting lanes around a central clearing.
- [level_018.json](../levels/level_018.json) — four-color coordination with two active slots.
- [level_019.json](../levels/level_019.json) — two full-capacity teams on opposite sides of the field.
- [level_020.json](../levels/level_020.json) — Meadow chapter midpoint mastery puzzle.

## Fields

| Field | Type | Rule |
|---|---|---|
| `schema_version` | integer | Must equal `1` |
| `id` | string | Required, non-empty stable identifier |
| `title`, `objective` | string | Player-facing level title and short instruction |
| `width`, `height` | integer | Each from 1 to 32 |
| `start`, `goal` | integer pair | `[x, y]`, inside board bounds |
| `deployment_slots` | integer | Required for playable campaign levels; 1–4 active squad slots |
| `squads` | array | Required for playable campaign levels; 1–8 `{ id, color, capacity }` definitions |
| `tiles` | array | Optional tile overrides; coordinates must be unique and in bounds |

Allowed tile types:

- `empty` — explicit empty cell.
- `resource` — collectible resource; must include a `color` value from `amber`, `teal`, `coral`, or `violet`.
- `obstacle` — impassable cell.
- `nest` — colony entrance / starting point.

Cells omitted from `tiles` are ordinary empty ground. Resource colors are part of the game rules, not presentation metadata: a squad may collect only a matching color. At most one tile definition may occupy a coordinate. The start and goal cannot be obstacles.

## Playable colony roster

Playable levels define `deployment_slots` and `squads`. A squad has a stable unique `id`, a `color` matching one of the four resource colors, and a `capacity` from 1 to 9. The number of deployment slots is from 1 to 4. The roster is validated as part of schema v1 and loaded by `LevelLoader`; malformed level data is rejected before it can be played.

## Validation

`scripts/core/level_definition.gd` validates the schema and returns:

- `valid`: whether the level passed validation.
- `errors`: actionable validation messages.
- `resource_count`: number of resource tiles.

Unknown schema versions fail explicitly. The format is intentionally small; new mechanics should use a new schema version or a documented backwards-compatible extension.

## Design constraints

- Keep level files deterministic and reviewable in Git.
- Never encode presentation-only state in level data.
- Every authored level must have a documented, verified solution before release.
- Do not silently reinterpret invalid or unknown tile types.
- [level_021.json](../levels/level_021.json) — Narrow Gate: single open passage and route commitment.
- [level_022.json](../levels/level_022.json) — Side Pocket: harvest pockets on opposite sides of a clearing.
- [level_023.json](../levels/level_023.json) — Three Stops: one capacity-three route through a scattered harvest.
- [level_024.json](../levels/level_024.json) — The Waiting Line: four squads competing for one deployment slot.
- [level_025.json](../levels/level_025.json) — Forked Harvest: two active slots and a split multi-color harvest.
- [level_026.json](../levels/level_026.json) — Two-Way Detour: two safe openings through a wall.
- [level_027.json](../levels/level_027.json) — Capacity Deadline: capacity-two harvest alongside two smaller teams.
- [level_028.json](../levels/level_028.json) — Four Openings: four-color routing around staggered stonework.
- [level_029.json](../levels/level_029.json) — The Last Seed Home: full amber load around a lower bend.
- [level_030.json](../levels/level_030.json) — The Meadow Crown: chapter exam combining capacity, slots, colors, and obstacles.
- [level_031.json](../levels/level_031.json) — Root Gate: a lower-only crossing forces a long detour to the upper chamber.
- [level_032.json](../levels/level_032.json) — Twin Rootways: two separated openings connect the nest to upper and lower chambers.
- [level_033.json](../levels/level_033.json) — The S-Bend: staggered walls create a forced two-stage corridor.
- [level_034.json](../levels/level_034.json) — The Root Weave: upper and lower branches are split by a central root.
- [level_035.json](../levels/level_035.json) — The Buried Junction: four harvest points are arranged beyond two narrow entrances.
- [level_036.json](../levels/level_036.json) — The Root Ladder: capacity-two harvest along a narrow upper corridor.
- [level_037.json](../levels/level_037.json) — Forked Roots: three colors beyond a forked passage.
- [level_038.json](../levels/level_038.json) — Parallel Tunnels: two teams can use separated openings while a third waits.
- [level_039.json](../levels/level_039.json) — The Narrow Seam: one crossing through a horizontal root wall.
- [level_040.json](../levels/level_040.json) — The Root Crown: four harvest points around a central heartwood mass.
- [level_041.json](../levels/level_041.json) — The Split Crossing: three harvest points beyond two narrow openings.
- [level_042.json](../levels/level_042.json) — The Long Burrow: capacity-two amber harvest beyond two turns.
- [level_043.json](../levels/level_043.json) — The Upper and Lower Roots: two horizontal channels around a root barrier.
- [level_044.json](../levels/level_044.json) — The Root Divide: upper and lower entries through a central wall.
- [level_045.json](../levels/level_045.json) — The Hollow Crown: four colors around a heartwood mass with upper and lower lanes.
- [level_046.json](../levels/level_046.json) — The Stair of Roots: two staggered crossings make an upper-then-lower route.
- [level_047.json](../levels/level_047.json) — Crossed Passages: three colors distributed around two aligned corridor gates.
- [level_048.json](../levels/level_048.json) — The Hidden Pocket: one seed sits in a side pocket with a single entrance.
- [level_049.json](../levels/level_049.json) — The Deep Turn: a central detour divides upper and lower chambers.
- [level_050.json](../levels/level_050.json) — The Labyrinth Heart: four-color checkpoint around two winding passages.

- [level_051.json](../levels/level_051.json) — The Bent Gate: offset root walls force a low crossing before the upper harvest.
- [level_052.json](../levels/level_052.json) — Twin Root Mouths: upper and lower chambers have separate entrances.
- [level_053.json](../levels/level_053.json) — The Turning Fork: staggered barriers make the route change sides between chambers.
- [level_054.json](../levels/level_054.json) — The Middle Passage: three harvest points share one crossing and two deployment slots.
- [level_055.json](../levels/level_055.json) — The Root Labyrinth Trial: four colors and alternating openings form the chapter's 25-level checkpoint.
