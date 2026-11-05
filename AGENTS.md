# Agent Operating Rules — Game-ANTS

## Source of truth
- GitHub Issues are the only task queue and source of task acceptance.
- Do not connect or use Feishu, chat platforms, external task trackers, or other task sources.
- The approved game-design and technical documents in this repository are the current product source of truth.
- If an issue conflicts with an approved document, stop and report the conflict instead of silently choosing.

## Branch and PR policy
- Never commit directly to `main`.
- Work only on a dedicated branch for the assigned issue, e.g. `feat/issue-12-short-description`.
- Keep changes scoped to the issue.
- Open a pull request to `main`; explain behavior, files changed, tests run, risks, and screenshots/video when visual behavior changes.
- Never merge a pull request. A human owner reviews and merges.
- Do not rewrite history or force-push unless explicitly authorized.

## Before coding
1. Read this file, README, and the relevant design/technical documents.
2. Read the assigned GitHub Issue and its acceptance criteria.
3. Inspect the existing project before making assumptions.
4. Post a short implementation plan in the issue or PR.
5. Preserve existing behavior unless the issue explicitly changes it.

## Engineering standards
- Prefer small, testable, reversible changes.
- Keep game rules separate from presentation and animation.
- Keep level data deterministic and data-driven.
- Avoid unnecessary dependencies and premature online services.
- Design for portrait mobile screens and touch input.
- Handle safe areas, different aspect ratios, pause/resume, and interrupted app sessions.
- Do not add ads, purchases, tracking, accounts, or network requirements without an approved issue.
- Never commit secrets, signing keys, tokens, personal data, or generated build artifacts.

## Verification
- Run all relevant automated checks.
- For gameplay changes, add or update tests for rules and edge cases.
- For UI changes, verify narrow and wide portrait aspect ratios and touch targets.
- Report tests that could not be run; never claim a test passed without running it.

## Checkpoints
At each milestone, update the relevant docs with:
- checkpoint ID and date;
- commit and branch;
- completed work;
- verification evidence;
- known issues and next task;
- exact checkpoint phrase for continuing in a new chat.

## Communication
Be concise, factual, and explicit about uncertainty. Never claim that a build, test, deployment, or installation succeeded unless its result was observed.

## Tooling policy
- The project is developed directly with ChatGPT and the connected GitHub tools; no external coding agent or agent harness is required.
- Do not install, configure, or introduce DeepSeek Harness or another external autonomous agent unless the project owner explicitly changes this decision.
- ChatGPT-assisted changes must follow the same branch, review, testing, and no-direct-merge rules above.
