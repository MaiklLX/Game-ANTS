# ANTWORKS — Game Design Document

**Version:** 0.1  
**Status:** Initial direction; prototype rules are not yet validated  
**Project:** Game-ANTS

## 1. Product vision

A polished, portrait-first mobile logic puzzle about directing a living ant colony through colorful, compact worlds. The player solves spatial and sequencing puzzles by deploying ant squads, managing limited colony capacity, and opening routes to resources.

The experience should be immediately understandable, tactile, satisfying to watch, and increasingly clever without relying on timers or punitive energy systems.

## 2. Audience and session

- Casual puzzle players who enjoy color logic, spatial planning, and pixel art.
- One-handed play with short sessions (roughly 1–5 minutes per level).
- Default mode is untimed; optional challenge variants may be considered later.
- Offline play is a core requirement for the puzzle campaign.

## 3. Design pillars

1. **One clear decision at a time:** a player should understand what a tap will do.
2. **A colony that feels alive:** ants move with purpose, carry resources, react to obstacles, and return to the nest.
3. **A puzzle, not a reflex test:** difficulty comes from planning, access, capacity, and move order.
4. **Visible progress:** the board changes in satisfying stages and reveals a complete piece of pixel art or a colony reward.
5. **Fair difficulty:** every failure should be explainable; undo/retry rules must be clear.

## 4. Reference analysis

The reference games demonstrate the appeal of:
- selecting a color group and watching a swarm clear matching pixels;
- limited holding capacity that makes move order important;
- pixel-art boards that are both the puzzle and the reward;
- simple touch controls and relaxed pacing.

Game-ANTS must not reproduce another game's exact levels, art, UI, wording, branding, or complete ruleset. We will use these genre patterns as a starting point and validate our own differentiators through a playable prototype.

## 5. Proposed core loop

1. Read the board: identify resource clusters, blocked routes, and available ant squads.
2. Select a squad from the nest queue.
3. Ants follow a valid route to accessible matching resources.
4. They collect resources and return to the nest; the squad's capacity is consumed.
5. Clearing resources may open new passages, expose hidden resources, or unlock another squad.
6. Complete the objective and receive a clear visual payoff.

## 6. Signature mechanic proposal: pheromone logistics

The differentiating system under consideration is **pheromone routing**:
- Ants prefer valid, established trails.
- Certain tiles can be marked, strengthened, redirected, or temporarily blocked.
- Different ant roles may interact with trails differently.
- A route change should have a visible, understandable consequence.

This is a proposal, not a locked rule. The first prototype should test whether pheromone routing creates meaningful choices without adding unnecessary complexity.

## 7. Secondary mechanics candidates

Introduce one at a time, only after the base loop is fun:
- **Tunnel gates:** one-way or switchable passages.
- **Load limits:** squads carry a fixed amount of resources.
- **Worker roles:** scout reveals, carrier transports, engineer modifies a small number of tiles.
- **Terrain:** mud slows, water blocks, bridges connect.
- **Hidden chambers:** clearing a layer reveals a new route or objective.
- **Colony upgrades:** long-term progression that changes options, not basic puzzle solvability.

## 8. Prototype scope (MVP)

The first playable prototype should contain:
- one portrait gameplay screen;
- a small board with 3–4 resource colors;
- a nest with a limited number of squad slots;
- deterministic ant movement and collection;
- at least one route/obstacle interaction;
- win, blocked/loss, retry, and undo behavior (undo may be deferred if it complicates state correctness);
- 10 hand-authored tutorial/prototype levels;
- clear touch feedback and basic movement/collection animation.

No shop, ads, accounts, online leaderboard, live events, or complex meta-progression in MVP.

## 9. Level design principles

- Teach one new idea at a time.
- Early levels must be solvable without guessing.
- Avoid color-only ambiguity: pair colors with shapes/patterns or labels for accessibility.
- Every puzzle must have a verified solution.
- Loss states must be caused by player choices, not hidden rules or animation timing.
- Level data should be deterministic and independent of presentation.

## 10. Progression proposal

Campaign chapters can represent different colony biomes (meadow, garden, forest floor, greenhouse, ruins). Each chapter introduces one environmental rule and a new visual theme. Cosmetic nest decoration and collectible pixel-art panels are possible later, but not part of the first prototype.

## 11. Open design questions to resolve with prototype evidence

- Is pheromone routing the primary differentiator, or should it be a later special mechanic?
- Does a squad return to its source, a shared nest, or a matching storage tile?
- Are slots occupied by squads until their whole load is delivered, or can ants work in parallel?
- Should the player have unlimited undo, limited undo, or no undo?
- What is the clearest visual language for resource colors and ant roles?

These questions should be answered by short playable experiments, not prolonged speculation.
