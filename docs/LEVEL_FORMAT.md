# Level data format — schema v1

Campaign levels are stored as UTF-8 JSON files under `levels/`. The file is data only; rendering and animation must not be embedded in it.

## Examples

- [level_001.json](../levels/level_001.json) — first collection and return.
- [level_002.json](../levels/level_002.json) — two resource colors with one deployment slot.
- [level_003.json](../levels/level_003.json) — two amber seeds, one teal seed, and capacity planning.
- [level_004.json](../levels/level_004.json) — two simultaneous squads, two deployment slots, and a narrow shared passage.

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
