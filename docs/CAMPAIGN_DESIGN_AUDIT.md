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
| The Amber Orchard | 5.88 | 0.81 | 13 |
| The Colony Heart: First Dawn | 5.52 | 0.42 | 11 |

The route length excludes the starting cell. Extra detour steps are the shortest route length minus Manhattan distance. Averages are weighted by individual resource samples, not by level.

This snapshot confirms that Root Labyrinth has the longest average and maximum individual resource routes. The final 10-level chapter is more compact by this individual-route metric, despite carrying more resources on average. The level-100 finale now compensates with a long shared-gate expedition, but this metric alone does not model sequential pickup routes, returns to the nest, squad capacity, simultaneous deployment, or player choice among alternatives.

### Deterministic test-solver workload

A second measurement follows the same deterministic per-color collection order used by the campaign integration test: each squad collects up to its capacity, then returns to the nest before its next trip. It sums movement steps and trip count across squads. It is a reproducible workload proxy, not an optimal strategy or a direct player-difficulty score.

| Chapter | Avg. movement steps per level | Avg. trips per level | Highest level workload |
|---|---:|---:|---:|
| The Living Meadow | 33.33 | 2.80 | 48 |
| The Root Labyrinth | 42.73 | 3.00 | 70 |
| The Amber Orchard | 35.13 | 3.03 | 56 |
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

The current top workload candidates are Root Labyrinth 056 (70), Colony Heart 100 and Root Labyrinth 035 (64 each), Root Labyrinth 053 and 057 (62 each), Root Labyrinth 055 and Orchard 065 (56 each), Orchard 085 (54), Orchard 078 (52), and Orchard 090 (50). Level 100 is now the heaviest level in its chapter and the second-heaviest in the full campaign by this deterministic workload proxy.



### Five-level workload progression

The audit groups deterministic movement into consecutive five-level bands to expose pacing changes inside each chapter. Values are average movement steps per level / average trips / maximum steps in the band.

| Levels | Meadow | Root Labyrinth | Amber Orchard | Colony Heart |
|---|---:|---:|---:|---:|
| 001–005 / 031–035 / 061–065 / 091–095 | 24.80 / 2.00 / 34 | 42.40 / 2.80 / 64 | 36.80 / 2.60 / 56 | 29.60 / 2.60 / 40 |
| 006–010 / 036–040 / 066–070 / 096–100 | 35.20 / 2.60 / 48 | 36.40 / 3.00 / 40 | 31.60 / 2.80 / 46 | 43.20 / 3.60 / 64 |
| 011–015 / 041–045 / 071–075 | 36.00 / 3.40 / 40 | 38.80 / 3.00 / 48 | 33.60 / 3.20 / 40 | — |
| 016–020 / 046–050 / 076–080 | 37.20 / 3.00 / 46 | 41.60 / 3.00 / 48 | 33.20 / 2.80 / 52 | — |
| 021–025 / 051–055 / 081–085 | 31.20 / 2.80 / 40 | 45.20 / 3.00 / 62 | 39.60 / 3.40 / 54 | — |
| 026–030 / 056–060 / 086–090 | 35.60 / 3.00 / 44 | 52.00 / 3.20 / 70 | 36.00 / 3.40 / 50 | — |

This is a workload trend, not a difficulty curve. The strongest progression signal is the Root Labyrinth's final ten levels (056–060), which rise to 52 average steps and peak at 70. The final chapter also rises sharply in 096–100, averaging 43.20 steps and peaking at 64. Meadow's opening five are deliberately lighter, then it holds a relatively steady band around 31–37 steps.

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
- `orchard_083` — moved the coral resource into the sheltered central lane to break the repeated four-corner resource pattern.
- `orchard_084` — reduced deployment slots to one, turning the same four-pocket layout into a deliberate squad-rotation puzzle.
- `colony_100` — rebuilt the finale around eight seeds in four paired colors, with each pair split across a single central root gate. Every far-side resource route must pass through that gate; each carrier uses its capacity-two load.
- Stable level IDs and campaign order are preserved. No new mechanics or schema changes were introduced.

The revised Root Labyrinth maps and final-level redesign have targeted route regression coverage. CI #629 passed all tests, the campaign audit, and the headless main-scene launch on the current map/test checkpoint.

## Next review sequence

1. Audit the level-by-level learning and workload progression inside each chapter, looking for sudden difficulty spikes or long flat stretches.
2. Review the crown/finale family (035, 040, 045, 050, 055, 060) at player-decision level, not only by route length.
3. Compare resource distribution, capacity, slot pressure, and concurrent deployment choices at level granularity; the deterministic solver is not an optimal player strategy.
4. Keep manual Godot Editor portrait review and real-device playtesting as separate release gates. Headless CI is not visual QA.


### Route-profile similarity groups

The refined route-profile signature compares deployment slots, each resource color's shortest nest-to-resource distance and number of shortest paths, and each squad's color/capacity. It ignores obstacle coordinates and full route shape, so matching groups are review prompts rather than automatic duplicates.

Only two groups remain after adding shortest-path multiplicity:

- Meadow 008 / Root Labyrinth 032 / 047
- Root Labyrinth 041 / 052

Both groups were compared against the actual JSON maps and path topology:

| Group | Shared profile | Why the puzzles remain distinct |
|---|---|---|
| Meadow 008 / Root 032 / Root 047 | Same three resource positions, colors, squad capacities, two slots, and shortest-path multiplicities | Meadow 008 alternates between two staggered gates; Root 032 has one wall with upper/lower mouths; Root 047 uses two successive aligned walls |
| Root 041 / Root 052 | Same color-by-color shortest distances and path counts | Root 041 places the coral cache beyond a shared central bottleneck; Root 052 places coral near the nest and sends far harvests through separate upper/lower mouths |

The earlier distance-only groups across Root Labyrinth and Amber Orchard were split by path multiplicity: their route lengths looked alike, but the number of shortest alternatives and therefore the route-choice pressure differed. The remaining two groups are intentional topology variations. **No further map changes are justified by route-profile similarity alone.**

This remains a data-level review. It does not replace Godot Editor visual inspection or player testing.

## Current status

- Campaign content: 100/100 authored.
- Root Labyrinth content: 30/30 authored; design sign-off remains open.
- Audit script: added to CI and expanded with route profiles, route lengths, and deterministic expedition workloads. CI #665 passed the latest Orchard route regressions; CI #672 passed the current full campaign audit and documentation checkpoint.
- Latest audit: **0 repeated board-geometry groups and 0 exact gameplay-signature groups** across all 100 levels. Two route-profile similarity groups remain after shortest-path multiplicity review; both were compared manually and retained as distinct puzzles.
- The final level 100 now records 64 deterministic movement steps across four trips, placing it at the top of its chapter and tied for second in the campaign. Every far-side resource route must cross the single central gate.
- Latest route snapshot: Root Labyrinth has the longest average shortest path to a resource (7.14 steps; max 15); the final chapter averages 5.52 (max 11). The final chapter's full deterministic expedition workload averages 36.40 steps/level and peaks at 64. Meadow averages 33.33 steps/level; Amber Orchard averages 35.13 after its route-profile revisions.
- PR #9 remains Draft and unmerged. No merge to `main` without explicit owner approval.
