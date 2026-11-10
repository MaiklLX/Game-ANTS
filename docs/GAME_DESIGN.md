# ANTWORKS / Муравьишки — Game Design Document

**Version:** 0.2  
**Status:** Active foundation; strategic prototype implemented, product shell in progress  
**Project:** Game-ANTS

## 1. Product vision

A friendly, portrait-first mobile strategy puzzle about a small ant colony exploring colorful environments, collecting seeds, and bringing them safely home. The player makes the important decisions; ants carry out clear orders with lively, readable movement.

The game should feel warm, tactile, calm, and rewarding — not like a spreadsheet or a sequence of tiny chess moves. The player plans destinations and expedition timing, while the colony handles the visual execution.

## 2. Audience and sessions

- Casual puzzle players who enjoy spatial logic, collection, and gentle progression.
- One-handed portrait play on Android first; iOS and desktop/web remain future validation targets.
- Short levels with a clear beginning, readable decisions, and a satisfying delivery moment.
- Core campaign playable offline. No account or network requirement for ordinary play.

## 3. Design pillars

1. Friendly clarity: every control communicates what will happen before it is tapped.
2. A living colony: ants have readable gait, cargo, routes, and reactions; the nest responds to deliveries.
3. Strategy without busywork: player chooses squads, targets, and returns; movement can be watched or accelerated, but decisions remain explicit.
4. Parallel expeditions: active squads advance together on one shared turn, making coordination meaningful.
5. Visible progress: seeds delivered, chapters explored, and levels completed are clearly remembered.
6. Comfort and accessibility: responsive portrait layout, pause on interruption, reduced-motion option, and optional haptic feedback.
7. Fairness: deterministic rules, visible day budget, no random penalties, and regression-tested level data.

## 4. Core gameplay contract

- The player selects and deploys a squad into an available colony slot.
- A squad may be assigned a matching-color resource target or an explicit return-to-nest order.
- Assigning an order does not move ants or collect resources.
- On a committed turn, every squad with a valid active order advances by one route cell.
- One shared day point is spent per committed turn, regardless of how many squads move.
- A resource is collected only when a matching squad reaches it and has carrying capacity.
- After collection, the squad waits. It does not choose another resource or return automatically.
- Cargo is delivered only when the player has ordered a return and the squad reaches the nest.
- Victory requires all objective resources to be delivered. The level is lost when the shared day budget expires first.
- Multiple squads may share tunnel cells; they do not create artificial traffic jams.
- The optional expedition run control automates only the repeated execution of already-issued orders. It stops at collection, delivery, blocked movement, or terminal state so the player can make the next decision.

## 5. Core loop

1. Read the board, available squads, resources, and shared day budget.
2. Deploy one or more squads within the available slots.
3. Assign matching resource targets and inspect route costs.
4. Commit turns manually or start the expedition run for already-issued orders.
5. Review collection feedback and choose the next orders.
6. Explicitly return loaded squads to deliver seeds and free their slots.
7. Complete the objective and continue through the campaign.

## 6. Campaign structure

The launch campaign currently contains 100 authored levels in four chapter packs: The Living Meadow, The Root Labyrinth, The Amber Orchard, and The Colony Heart: First Dawn.

Chapter and level identities are stable IDs. The level selector's page arrows only change the visible slice; they do not represent progression or lock content. The player can currently choose any authored level.

The campaign audit screens for duplicate geometry and gameplay signatures, measures route/workload patterns, and reports review candidates. Automated validation is a screening tool, not proof that every puzzle is enjoyable or optimally balanced.

## 7. Product shell

The application foundation is being built around five clear destinations:
- Main menu: continue, start a new game, choose a chapter, open settings.
- Chapter selection: enter a chapter at its first authored level.
- Gameplay: board, squads, route orders, day budget, level picker, progress.
- Pause: resume, restart, settings, return to main menu.
- Settings: reduced motion and optional haptic feedback.

The app pauses active expedition playback when it loses focus or is backgrounded. It must never continue moving ants invisibly while the player is away.

## 8. Accessibility and comfort

- Reduced motion shortens movement transitions.
- Haptics can be disabled independently.
- Resource colors are also represented by distinct geometric marks and letters.
- UI uses safe-area-aware responsive portrait layout and large touch targets.
- Additional accessibility work (text scaling, contrast review, screen-reader semantics) remains on the roadmap.

## 9. Scope boundaries

Not part of the current foundation:
- monetization, ads, analytics, accounts, cloud sync, leaderboards, or live events;
- procedural generation or random difficulty modifiers;
- autonomous dispatch, autonomous resource selection, or automatic return;
- complex ant classes, fatigue, weather, gates, or pheromone simulation;
- audio sliders until music and sound-effect buses actually exist;
- a full economy or colony-upgrade tree before the core campaign is validated.

## 10. Quality gates

- Deterministic unit and contract tests for rules, persistence, settings, and campaign data.
- Godot import, headless launch, campaign audit, and rendered portrait screenshot checks in CI.
- Android debug export as a separate build gate.
- Manual editor review and physical-device touch/safe-area testing remain separate release gates. A successful headless run is not a device test.
