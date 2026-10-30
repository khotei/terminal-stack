# Roadmap

The tickets that come next for **terminal-stack**. This file is the **only place a future ticket
exists** before its `/ticket-feature` runs: an entry holds what a ticket is *for* (goal, scope, out
of scope, dependencies, open questions); the *how* is decided by `/ticket-architecture` inside the
ticket. When a ticket starts, `/ticket-feature <slug>` reads its entry, grills from there, and the
entry's status becomes a link to the ticket folder.

- **One ticket = one branch `<type>/<slug>` cut from `main` = one squash-merged PR**
  (`.claude/rules/sdd.md`).
- **Order below is the default, dependencies are the law.** A ticket may start when every entry in
  its `Depends on` is done; two independent tickets may run in parallel on separate branches.
- **Facts expire.** Every `Facts` line carries the date it was checked; `/ticket-feature`
  re-verifies the ones it relies on and moves them into the ticket's `feature.md › Context`.
- Work done before this roadmap was tracked in Notion and is not carried over; its commits keep
  their `Refs:` links.

## Tickets

| # | Ticket | Type | Depends on | Status |
|---|---|---|---|---|
| 1 | [`sdd-in-git`](#1-sdd-in-git) | `chore` | — | in progress: [docs/tickets/2026-10-30-2031_sdd-in-git/](../tickets/2026-10-30-2031_sdd-in-git/feature.md) |
| 2 | [`shared-toolkit`](#2-shared-toolkit) | `chore` | 1 | planned |

### 1. `sdd-in-git`

- **Goal.** The spec-driven loop runs from files in this repository, after `app-template`'s model,
  with no Notion connector.
- **Status.** In progress: [docs/tickets/2026-10-30-2031_sdd-in-git/](../tickets/2026-10-30-2031_sdd-in-git/feature.md).

### 2. `shared-toolkit`

- **Goal.** One copy of the ticket skills and the agents, shared by this repo and `app-template`,
  so a lesson learned in one reaches the other.
- **Scope.** Extract what both copies hold identically into a plugin both repos enable; keep the
  stack-specific lines (the check command, the kinds of evidence) as each repo's own override.
- **Out of scope.** Changing the loop's gates.
- **Open questions for its feature phase.** Whether a plugin's skills can be overridden per repo
  without copying them; where the plugin lives (its own repo, or one of the two); how a repo pins
  its version.
- **Facts (2026-10-30).** Both repos hold the skills at `.claude/skills/ticket-*/SKILL.md` and the
  guide and roadmap at `docs/knowledge/`, so the copies can be diffed file by file.
