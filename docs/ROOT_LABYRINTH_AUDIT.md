# Root Labyrinth — chapter-level design audit

**Date:** 2026-11-05  
**Branch:** `feat/kt-006-scalable-campaign-catalog`  
**Reviewed content:** levels 031–060, chapter pack, production level solver, route-shape regression tests, BoardModel and TurnResolver.

## Executive finding

The chapter is structurally valid and all 30 levels are included in the deterministic production-rule campaign solver. The first review found a genuine repetition cluster; targeted revisions have since removed the exact map duplicates. Similar route motifs remain under review. Automated solvability must not be treated as proof of puzzle variety or a balanced difficulty curve.

## Confirmed strengths

- The chapter uses only schema-v1 mechanics already implemented: static obstacles, colored resources, squad capacity, deployment slots, and deterministic shortest paths.
- The authored progression introduces single gates, separated openings, staggered bends, side pockets, capacity-two collection, and multi-color finales.
- Special route checks cover representative long detours (031, 033, 035, 042, 048, 051, 056), both branches in 034, the single upper-notch cache in 045, and all four targets in 060.
- The campaign integration test loads each level and completes every resource collection/return with the production models. No level in the current set is missing from the test path list.

## Design risks found

### 1. Repeated three-lane topology

**Resolved in KT-009:** levels 037 and 041 were redesigned. `root_037` now routes around a central heartwood island using upper/lower branches; `root_041` now sends every far-side route through one shared gate. The latest campaign audit reports zero repeated board-geometry groups and zero exact gameplay-signature groups across all 100 levels.

### 2. Related central-wall / alternating-opening motifs

Several levels reuse close variations of the same vertical barrier pattern:
- 032 uses a single central barrier with three resources in matching positions later reused by related layouts.
- 038 and 041 repeat the three-lane fork arrangement.
- 047 adds a second barrier to a similar three-resource layout.
- 057 and 059 both emphasize alternating openings across two walls.

These are legitimate variations only when the route decision, resource order, or slot/capacity pressure changes meaningfully. The campaign-wide route-profile screen now groups similar shortest-path workloads for human review; it does not classify them as duplicates.

### 3. Related four-resource crown/finale patterns

Levels 035, 040, 045, 050, 055, and 060 share a broad four-color/corridor theme. `root_045` has since been redesigned as a central coral cache behind one upper notch, with four squads limited to two slots. The multiplicity-aware route-profile audit distinguishes `root_040` and `root_050`: `root_040` offers three shortest routes to each far resource, while `root_050` constrains both far resources to one shortest route. Their obstacle layouts and route-choice pressure are meaningfully different.

### 4. Test coverage gap: solvability vs. strategic variety

The integration solver completes each color's resources in a fixed roster order, deploying and returning squads as needed. This is valuable regression coverage for reachability, matching colors, capacity, and completion. It does not establish that:
- the player has a meaningful choice of expedition order;
- simultaneous deployment creates a distinct strategic trade-off;
- two levels require different plans;
- the difficulty curve is smooth or phone-readable.

The route-shape suite checks selected representative targets, not the full route-cost profile of every resource in every level.

## Required follow-up before release sign-off

1. **Completed:** redesign `root_037` and `root_041`; the campaign-wide geometry audit now reports zero repeated geometry groups.
2. **Completed:** refine `root_053` with an intermediate pickup and add route-identity regressions; CI validates the lower-first / upper-second route sequence.
3. **Completed:** add campaign-wide geometry, gameplay-signature, route-profile, and deterministic expedition-workload audits. Route-profile matches remain review candidates, not automatic defects.
4. **Reviewed:** the 047/057/059 barrier family and 040/050 crown pair have distinct shortest-path multiplicities and obstacle topologies; retain their variations rather than making cosmetic changes.
5. **Outstanding release gate:** perform a manual chapter playthrough in Godot Editor on a portrait-sized viewport and on real devices. CI headless launch is not visual QA.

## Decision

**Chapter content: 30/30 authored; automated validation passed; exact map duplicates removed; human design and visual sign-off remain open.** Do not expand these findings into a claim that all levels have been manually playtested. Do not introduce water, gates, switches, pheromones, or other unprototyped mechanics to solve a variety problem.

## Next production step

Continue the campaign-wide route-profile review, especially the 047/057/059 barrier family and 040/050 crown pair. New revisions must create a distinct decision pattern, not just new coordinates or colors.
