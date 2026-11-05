# Level data format — schema v1

Campaign levels are stored as UTF-8 JSON files under `levels/`. The file is data only; rendering and animation must not be embedded in it.

## Example

See [level_001.json](../levels/level_001.json).

## Fields

| Field | Type | Rule |
|---|---|---|
| `schema_version` | integer | Must equal `1` |
| `id` | string | Required, non-empty stable identifier |
| `width`, `height` | integer | Each from 1 to 32 |
| `start`, `goal` | integer pair | `[x, y]`, inside board bounds |
| `tiles` | array | Optional tile overrides; coordinates must be unique and in bounds |

Allowed tile types:

- `empty` — explicit empty cell.
- `resource` — collectible resource; must include a `color` value from `amber`, `teal`, `coral`, or `violet`.
- `obstacle` — impassable cell.
- `nest` — colony entrance / starting point.

Cells omitted from `tiles` are ordinary empty ground. Resource colors are part of the game rules, not presentation metadata: a squad may collect only a matching color. At most one tile definition may occupy a coordinate. The start and goal cannot be obstacles.

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
