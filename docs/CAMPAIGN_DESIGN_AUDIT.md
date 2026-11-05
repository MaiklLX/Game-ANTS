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
| The Living Meadow | 6.08 | 0.79 | 11 |
| The Root Labyrinth | 7.14 | 1.22 | 15 |
| The Amber Orchard | 5.87 | 0.79 | 13 |
| The Colony Heart: First Dawn | 5.52 | 0.42 | 11 |

The route length excludes the starting cell. Extra detour steps are the shortest route length minus Manhattan distance. Averages are weighted by individual resource samples, not by level.

This snapshot confirms that Root Labyrinth has the longest average and maximum individual resource routes. The final 10-level chapter is more compact by this individual-route metric, despite carrying more resources on average. The level-100 finale now compensates with a long shared-gate expedition, but this metric alone does not model sequential pickup routes, returns to the nest, squad capacity, simultaneous deployment, or player choice among alternatives.

### Deterministic test-solver workload

A second measurement follows the same deterministic per-color collection order used by the campaign integration test: each squad collects up to its capacity, then returns to the nest before its next trip. It sums movement steps and trip count across squads. It is a reproducible workload proxy, not an optimal strategy or a direct player-difficulty score.

| Chapter | Avg. movement steps per level | Avg. trips per level | Highest level workload |
|---|---:|---:|---:|
| The Living Meadow | 33.33 | 2.80 | 48 |
| The Root Labyrinth | 42.73 | 3.00 | 70 |
| The Amber Orchard | 34.80 | 3.03 | 56 |
| The Colony Heart: First Dawn | 36.40 | 3.10 | 64 |

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
| 100 | 64 | 4 |

The current top workload candidates are Root Labyrinth 056 (70), Colony Heart 100 and Root Labyrinth 035 (64 each), Root Labyrinth 053 and 057 (62 each), Root Labyrinth 055 and Orchard 065 (56 each), and Orchard 085 (54). Level 100 is now the heaviest level in its chapter and the second-heaviest in the full campaign by this deterministic workload proxy.



## Initial repeated-geometry findings

The first audit on the pre-revision 100-level branch found:

- `root_037`, `root_038`, and `root_041` shared the same board geometry.
- `root_038` and `root_041` also had identical resource colors, squad capacities, deployment slots, start, and goal. Their titles/objectives differed, but the underlying puzzle configuration did not. This was a genuine content duplicate.
- `root_053` and `root_056` initially shared geometry. The violet resource in `root_053` was moved to the lower intermediate segment before the second gate, giving it a distinct route-order decision while preserving the staggered corridor theme.

Related motifs across levels 047, 057, and 059 and the repeated crown/finale family (035, 040, 045, 050, 055, 060) remain candidates for human review. Their geometry is not automatically equivalent.

## Targeted revisions completed

- `root_037` — replaced the repeated single-wall footprint with a central heartwood island and upper/lower branch routes. The resource layout now asks the player to choose which side of the fork to clear first.
- `root_041` — replaced the duplicate of `root_038` with a single-cell bottleneck that feeds a three-way harvest junction; all far branches must pass through the same gate.
- `root_053` — moved the violet cache to the lower intermediate segment between two staggered gates, creating a distinct route-order decision from `root_056`.
- `root_045` — moved the coral cache into a central hollow accessible only through the upper notch and reduced deployment slots from three to two; regression coverage locks the single-entry route.
- `colony_100` — rebuilt the finale around eight seeds in four paired colors, with each pair split across a single central root gate. Every far-side resource route must pass through that gate; each carrier uses its capacity-two load.
- Stable level IDs and campaign order are preserved. No new mechanics or schema changes were introduced.

The revised Root Labyrinth maps and final-level redesign have targeted route regression coverage. CI #629 passed all tests, the campaign audit, and the headless main-scene launch on the current map/test checkpoint.

## Next review sequence

1. Review the route-profile similarity groups below. These are not map duplicates: they share shortest-route lengths, squad profiles, and slot counts, but may have different geometry and decision structure.
2. Review the related barrier motifs across levels 047, 057, and 059, plus the crown/finale family (035, 040, 045, 050, 055, 060), for genuinely different route decisions.
3. Compare resource distribution, capacity, slot pressure, and concurrent deployment choices at level granularity; the deterministic solver is not an optimal player strategy.
4. Keep manual Godot Editor portrait review and real-device playtesting as separate release gates. Headless CI is not visual QA.


### Route-profile similarity groups

The audit's route-profile signature compares deployment slots, the multiset of shortest nest-to-resource distances by color, and each squad's color/capacity. It deliberately ignores obstacle coordinates and route shape. These groups are review prompts, not duplicates:

- Meadow 005 / 011
- Meadow 008 / Root Labyrinth 032 / 047
- Meadow 016 / 021
- Root Labyrinth 031 / 051
- Root Labyrinth 034 / 038 / 043 / 059
- Root Labyrinth 040 / 050
- Root Labyrinth 041 / 052
- Amber Orchard 069 / 078 / 083 / 084 / Colony Heart 094

For example, Root Labyrinth 034, 038, 043, and 059 have different obstacle layouts and corridor topologies despite similar resource-distance and squad profiles. They should be judged by the decisions they ask the player to make, not by this signature alone. The Meadow 005/011 and 013/018 route-profile matches were removed by targeted redesigns; the audit now reports seven groups rather than nine.

## Current status

- Campaign content: 100/100 authored.
- Root Labyrinth content: 30/30 authored; design sign-off remains open.
- Audit script: added to CI and expanded with route profiles, route lengths, and deterministic expedition workloads. CI #629 passed the level-100 finale regression; CI #641 passed the Meadow 011/018 route regressions; CI #651/#652 passed the latest campaign and documentation checkpoint.
- Latest audit: **0 repeated board-geometry groups and 0 exact gameplay-signature groups** across all 100 levels. Seven route-profile similarity groups remain as review candidates; these are not exact duplicates.
- The final level 100 now records 64 deterministic movement steps across four trips, placing it at the top of its chapter and tied for second in the campaign. Every far-side resource route must cross the single central gate.
- Latest route snapshot: Root Labyrinth has the longest average shortest path to a resource (7.14 steps; max 15); the final chapter averages 5.52 (max 11). The final chapter's full deterministic expedition workload averages 36.40 steps/level and peaks at 64. Meadow now averages 33.33 steps/level after its two route-profile revisions.
- PR #9 remains Draft and unmerged. No merge to `main` without explicit owner approval.
