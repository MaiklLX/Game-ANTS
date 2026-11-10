# Tests

Headless tests for deterministic game rules and persistence belong here. Tests must not depend on animation timing or rendering.

Current coverage includes:
- board geometry and deterministic pathfinding;
- level schema and campaign catalog;
- colony roster, slots, capacity, collection, and delivery;
- strategic turn resolution and parallel expeditions;
- campaign progression and localization;
- progress persistence and recovery;
- accessibility settings persistence and future-schema protection;
- tutorial, contextual guidance, and responsive portrait layout.

Rendered screenshot checks are maintained separately in capture_mobile_layout.gd and run in CI.
