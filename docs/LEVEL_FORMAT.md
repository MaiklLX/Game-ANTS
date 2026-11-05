# Level data format — schema v1

Campaign levels are stored as UTF-8 JSON files and discovered through a manifest chain. The file is data only; rendering and animation must not be embedded in it.

## Scalable campaign layout

- `campaign/campaign_manifest.json` is the root index. It lists chapter-pack manifest files in campaign order.
- Each `campaign/packs/<chapter>/pack.json` defines one chapter and lists its level IDs and JSON file paths in play order.
- Each level JSON remains an independent file under `levels/` (or a future content directory).
- `CampaignCatalog` expands the manifest chain, validates each pack and level, rejects duplicate chapter IDs, level IDs, and file references, and returns a flat ordered catalogue to the game.
- The UI shows five levels at a time and pages through the catalogue. The game no longer has a hard-coded list of level paths.

The current meadow pack contains the five prototype levels. The architecture has no five-level or 300-level cap: the 300-level target is a content-production goal, not a hard-coded engine limit.

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
