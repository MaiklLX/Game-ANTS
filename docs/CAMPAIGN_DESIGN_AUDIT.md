# Campaign design audit — KT-009

## Purpose and limits

This audit is a repeatable screening tool for the 100-level launch campaign. It reports exact board-geometry matches, exact gameplay-signature matches, and chapter-level averages for resource count, obstacle count, squad count, deployment slots, and maximum carrying capacity.

A matching signature is a review signal, not an automatic design defect. Different resource colors, squad capacities, deployment-slot limits, route order, and intended teaching goals can make similar geometry play differently. Conversely, different geometry can still produce the same decision. Automated solvability remains necessary but does not prove puzzle quality, strategic variety, difficulty, or phone readability.

The audit runs in Godot CI through `tests/audit_campaign_design.gd`.

## First 100-level baseline

The first full audit reported:

| Chapter | Levels | Avg. resources | Avg. obstacles | Avg. squads | Avg. slots | Max capacity |
|---|---:|---:|---:|---:|---:|---:|
| The Living Meadow | 30 | 3.37 | 4.10 | 2.70 | 1.77 | 3 |
| The Root Labyrinth | 30 | 3.07 | 6.17 | 3.00 | 1.80 | 2 |
| The Amber Orchard | 30 | 4.50 | 5.10 | 3.00 | 1.87 | 3 |
| The Colony Heart: First Dawn | 10 | 4.80 | 4.30 | 3.10 | 2.00 | 3 |

These are content-shape indicators only. They are not a difficulty score. In particular, the lower obstacle average in the final chapter does not imply easier puzzles; resource density, squad capacity, slots, route structure, and decision order also matter.

## Initial repeated-geometry findings

The first audit on the pre-revision 100-level branch found:

- `root_037`, `root_038`, and `root_041` shared the same board geometry.
- `root_038` and `root_041` also had identical resource colors, squad capacities, deployment slots, start, and goal. Their titles/objectives differed, but the underlying puzzle configuration did not. This was a genuine content duplicate.
- `root_053` and `root_056` remain the only shared-geometry pair after revision. They differ in deployment-slot pressure and squad roster/color assignment; keep this pair under review rather than treating it as an exact gameplay duplicate.

Related motifs across levels 047, 057, and 059 and the repeated crown/finale family (035, 040, 045, 050, 055, 060) remain candidates for human review. Their geometry is not automatically equivalent.

## Targeted revisions in progress

- `root_037` — replaced the repeated single-wall footprint with a central heartwood island and upper/lower branch routes. The resource layout now asks the player to choose which side of the fork to clear first.
- `root_041` — replaced the duplicate of `root_038` with a single-cell bottleneck that feeds a three-way harvest junction; all far branches must pass through the same gate.
- Stable level IDs and campaign order are preserved. No new mechanics or schema changes were introduced.

The first redesign pass removed the exact duplicate, and CI #584 passed that interim version. A second refinement then made `root_041` a true single-gate branching puzzle and added route-identity regression tests for both revised maps; this newest refinement is awaiting CI. The renewed audit on the interim pass reported zero exact gameplay duplicates and one remaining geometry pair below.

## Next review sequence

1. Confirm CI for the `root_037` and `root_041` revisions and rerun the geometry report.
2. Review the `root_053` / `root_056` shared motif and the related barrier families in the Root Labyrinth.
3. Compare the full chapter progression using route length, bottleneck placement, resource distribution, capacity, and slot pressure; averages alone are insufficient.
4. Add targeted route/decision regression checks for any revised puzzle where a distinctive route shape is part of its identity.
5. Keep manual Godot Editor portrait review and real-device playtesting as separate release gates. Headless CI is not visual QA.

## Current status

- Campaign content: 100/100 authored.
- Root Labyrinth content: 30/30 authored; design sign-off remains open.
- Audit script: added to CI; run #579 passed on the baseline and run #584 passed after the map revisions.
- Latest map revisions: `root_037` and `root_041`; CI #584 passed the first revision pass. The follow-up `root_041` single-gate refinement and route-identity tests are now queued in CI run #591.
- The last completed audit (on the first revision pass) found zero exact gameplay-signature duplicate groups and one shared geometry pair (`root_053` / `root_056`). Root Labyrinth averaged 6.33 obstacles per level in that pass.
- PR #9 remains Draft and unmerged. No merge to `main` without explicit owner approval.
