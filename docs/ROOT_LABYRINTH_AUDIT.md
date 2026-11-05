# Root Labyrinth — chapter-level design audit

**Date:** 2026-11-05  
**Branch:** `feat/kt-006-scalable-campaign-catalog`  
**Reviewed content:** levels 031–060, chapter pack, production level solver, route-shape regression tests, BoardModel and TurnResolver.

## Executive finding

The chapter is structurally valid and all 30 levels are included in the deterministic production-rule campaign solver. The content review nevertheless finds a noticeable repetition cluster in the map layouts. Automated solvability must not be treated as proof of puzzle variety or a balanced difficulty curve.

## Confirmed strengths

- The chapter uses only schema-v1 mechanics already implemented: static obstacles, colored resources, squad capacity, deployment slots, and deterministic shortest paths.
- The authored progression introduces single gates, separated openings, staggered bends, side pockets, capacity-two collection, and multi-color finales.
- Special route checks cover representative long detours (031, 033, 035, 042, 048, 051, 056), both branches in 034 and 045, and all four targets in 060.
- The campaign integration test loads each level and completes every resource collection/return with the production models. No level in the current set is missing from the test path list.

## Design risks found

### 1. Repeated three-lane topology

Levels 037, 038, and 041 share the same obstacle coordinates and the same three resource coordinates. Their squad roster and resource colors differ, but the player's spatial problem is effectively the same. This is the clearest case of map-level duplication and should be corrected before the chapter is treated as final release-quality content.

### 2. Related central-wall / alternating-opening motifs

Several levels reuse close variations of the same vertical barrier pattern:
- 032 uses a single central barrier with three resources in matching positions later reused by related layouts.
- 038 and 041 repeat the three-lane fork arrangement.
- 047 adds a second barrier to a similar three-resource layout.
- 057 and 059 both emphasize alternating openings across two walls.

These are legitimate variations only when the route decision, resource order, or slot/capacity pressure changes meaningfully. Some currently differ more in roster or colors than in spatial reasoning.

### 3. Related four-resource crown/finale patterns

Levels 035, 040, 045, 050, 055, and 060 all use four-color or multi-lane combinations around central obstacle structures. The sequence does add pressure and complexity, but the chapter needs stronger visual/topological contrast between its mid-chapter checkpoints and finales.

### 4. Test coverage gap: solvability vs. strategic variety

The integration solver completes each color's resources in a fixed roster order, deploying and returning squads as needed. This is valuable regression coverage for reachability, matching colors, capacity, and completion. It does not establish that:
- the player has a meaningful choice of expedition order;
- simultaneous deployment creates a distinct strategic trade-off;
- two levels require different plans;
- the difficulty curve is smooth or phone-readable.

The route-shape suite checks selected representative targets, not the full route-cost profile of every resource in every level.

## Required follow-up before release sign-off

1. Redesign at least one of levels 037/038/041 so the three maps no longer share an identical obstacle/resource footprint.
2. Revisit the 047/057/059 family and ensure each teaches a distinct route decision, not just a denser version of the same barrier.
3. Add explicit tests for unique authored map signatures in the Root Labyrinth pack, while allowing intentional thematic motifs when their puzzle purpose is documented.
4. Perform a manual chapter playthrough in Godot Editor on a portrait-sized viewport. CI headless launch is not visual QA.
5. Reassess the final difficulty curve after map revisions and rerun the full CI suite.

## Decision

**Chapter content: 30/30 authored; automated validation passed; design audit requires targeted revision before release-quality sign-off.** Do not expand these findings into a claim that all levels have been manually playtested. Do not introduce water, gates, switches, pheromones, or other unprototyped mechanics to solve a variety problem.

## Next production step

Begin The Amber Orchard (061–090) in reviewed batches of five, but preserve a separate revision task for the Root Labyrinth duplication cluster. New levels must add a genuinely new decision pattern, not just new coordinates or colors.
