# Campaign design audit — KT-009

## Purpose and limits

This audit is a repeatable screening tool for the 100-level launch campaign. It reports exact board-geometry matches, exact gameplay-signature matches, and chapter-level averages for resource count, obstacle count, squad count, deployment slots, and maximum carrying capacity.

A matching signature is a review signal, not an automatic design defect. Different resource colors, squad capacities, deployment-slot limits, route order, and intended teaching goals can make similar geometry play differently. Conversely, different geometry can still produce the same decision. Automated solvability remains necessary but does not prove puzzle quality, strategic variety, difficulty, or phone readability.

The audit runs in Godot CI through `tests/audit_campaign_design.gd`. It uses the production board pathfinder for shortest nest-to-resource route measurements and reproduces the campaign test's deterministic capacity-based expedition sequence.

## First 100-level baseline

The first full audit reported:

| Chapter | Levels | Avg. resources | Avg. obstacles | Avg. squads | Avg. slots | Max capacity |
|---|---:|---:|---:|---:|---:|---:|
| The Living Meadow | 30 | 3.37 | 4.10 | 2.70 | 1.77 | 3 |
| The Root Labyrinth | 30 | 3.07 | 6.17 | 3.00 | 1.80 | 2 |
| The Amber Orchard | 30 | 4.50 | 5.10 | 3.00 | 1.87 | 3 |
| The Colony Heart: First Dawn | 10 | 4.80 | 4.30 | 3.10 | 2.00 | 3 |

These are content-shape indicators only. They are not a difficulty score. In particular, the lower obstacle average in the final chapter does not imply easier puzzles; resource density, squad capacity, slots, route structure, and decision order also matter.

## Latest shortest-route snapshot

The audit now measures the shortest path from the nest to each resource independently, using the production board pathfinder.

| Chapter | Avg. route to a resource (steps) | Avg. extra detour steps | Longest resource route (steps) |
|---|---:|---:|---:|
| The Living Meadow | 6.10 | 0.77 | 11 |
| The Root Labyrinth | 7.10 | 1.17 | 15 |
| The Amber Orchard | 5.87 | 0.79 | 13 |
| The Colony Heart: First Dawn | 5.56 | 0.46 | 11 |

The route length excludes the starting cell. Extra detour steps are the shortest route length minus Manhattan distance. Averages are weighted by individual resource samples, not by level.

This snapshot confirms that Root Labyrinth has the longest average and maximum individual resource routes. The final 10-level chapter is more compact by this metric, despite carrying more resources on average and using a slightly higher average slot count. That is a useful pacing question for the next review, not proof that the finale is too easy: this metric does not model sequential pickup routes, returns to the nest, squad capacity, simultaneous deployment, or player choice among alternatives.

### Deterministic test-solver workload

A second measurement follows the same deterministic per-color collection order used by the campaign integration test: each squad collects up to its capacity, then returns to the nest before its next trip. It sums movement steps and trip count across squads. It is a reproducible workload proxy, not an optimal strategy or a direct player-difficulty score.

| Chapter | Avg. movement steps per level | Avg. trips per level | Highest level workload |
|---|---:|---:|---:|
| The Living Meadow | 33.20 | 2.80 | 48 |
| The Root Labyrinth | 42.47 | 3.00 | 70 |
| The Amber Orchard | 34.80 | 3.03 | 56 |
| The Colony Heart: First Dawn | 34.40 | 3.10 | 48 |

The ten finale levels currently score:

| Level | Steps | Trips |
|---|---:|---:|
| 091 | 20 | 2 |
| 092 | 24 | 2 |
| 093 | 36 | 3 |
| 094 | 40 | 4 |
| 095 | 28 | 2 |
| 096 | 34 | 3 |
| 097 | 30 | 3 |
| 098 | 48 | 4 |
| 099 | 40 | 4 |
| 100 | 44 | 4 |

The current top workload candidates are Root Labyrinth 056 (70), 035 (64), 053 and 057 (62 each), 055 and Orchard 065 (56 each), and Orchard 085 (54). The finale's heaviest level is 098 (48), slightly above 100 (44). This does not prove level 100 is too easy, but it makes the finale's climax and decision density a clear human-review target.



## Initial repeated-geometry findings

The first audit on the pre-revision 100-level branch found:

- `root_037`, `root_038`, and `root_041` shared the same board geometry.
- `root_038` and `root_041` also had identical resource colors, squad capacities, deployment slots, start, and goal. Their titles/objectives differed, but the underlying puzzle configuration did not. This was a genuine content duplicate.
- `root_053` and `root_056` initially shared geometry. The violet resource in `root_053` was moved to the lower intermediate segment before the second gate, giving it a distinct route-order decision while preserving the staggered corridor theme.

Related motifs across levels 047, 057, and 059 and the repeated crown/finale family (035, 040, 045, 050, 055, 060) remain candidates for human review. Their geometry is not automatically equivalent.

## Targeted revisions in progress

- `root_037` — replaced the repeated single-wall footprint with a central heartwood island and upper/lower branch routes. The resource layout now asks the player to choose which side of the fork to clear first.
- `root_041` — replaced the duplicate of `root_038` with a single-cell bottleneck that feeds a three-way harvest junction; all far branches must pass through the same gate.
- Stable level IDs and campaign order are preserved. No new mechanics or schema changes were introduced.

The first redesign pass removed the exact duplicate, and CI #584 passed that interim version. A second refinement then made `root_041` a true single-gate branching puzzle and added route-identity regression tests for both revised maps. CI #591 passed this refined version; its renewed audit reports zero exact gameplay duplicates and one remaining geometry pair below.

## Next review sequence

1. Review the remaining related barrier motifs across levels 047, 057, and 059, and the repeated crown/finale family (035, 040, 045, 050, 055, 060) for genuinely different route decisions.
2. Compare the full chapter progression using route length, bottleneck placement, resource distribution, capacity, and slot pressure; averages alone are insufficient.
3. Add targeted route/decision regression checks where a distinctive route shape is part of a level's identity.
4. Keep manual Godot Editor portrait review and real-device playtesting as separate release gates. Headless CI is not visual QA.

## Current status

- Campaign content: 100/100 authored.
- Root Labyrinth content: 30/30 authored; design sign-off remains open.
- Audit script: added to CI; runs #579, #597, #599, and #605 passed. PR validation run #606 passed too.
- Latest map revisions: `root_037`, `root_041`, and `root_053`; run #599 passed the route-identity tests and the campaign-wide audit. Result: **0 repeated geometry groups and 0 exact gameplay-signature groups** across 100 levels.
- Latest route snapshot: Root Labyrinth has the longest average shortest path to a resource (7.10 steps; max 15); the final chapter is shortest (5.56; max 11). These figures do not account for expedition sequencing, returns, or slot/capacity interactions.
- PR #9 remains Draft and unmerged. No merge to `main` without explicit owner approval.
