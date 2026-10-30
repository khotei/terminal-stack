# SDD in git

> Ticket: `2026-10-30-2031_sdd-in-git` · Source: conversation — the review of `app-template`'s
> toolkit against this repo (2026-10-30)
> Related: [architecture.md](./architecture.md) · [plan.md](./plan.md)

## Problem

A change here is meant to run through the spec-driven loop, but the loop lives in Notion: features,
tasks, research and verify reports are Notion rows, and the seven `/sdd:*` commands are generated
from a Notion hub page. Without a Notion connector nothing runs, and a reader of this public repo
cannot reach the spec behind a commit. In practice the last ~40 commits skipped the loop: their
`Refs:` point at upstream docs, not at a spec. Nothing stops an implementer from reporting a change
whose config does not load, and no review sits between its work and the commit.

## Goal

Every change of substance runs feature → architecture → plan → implement → verify with all its
artifacts as files in this repository, the way `app-template` already works: a commit leads to its
spec, no external service is needed, every step is reviewed and approved before it is committed,
and every ticket ends with lessons that become checks or rule lines. Now, because the two repos
drifted apart and the lessons `app-template` paid for do not reach this one.

## Context

- **The toolkit today:** seven commands `.claude/commands/sdd:*.md` plus `check.md` and an index;
  six agents (`spec-author`, `planner`, `task-splitter`, `researcher`, `implementer`, `verifier`);
  a bundle `.claude/sdd/` (templates, a property contract, the Notion data-source ids); and
  `.claude/rules/sdd.md`, the build contract. All of it is generated from the Notion hub.
- **`/sdd:implement` runs in the main session** and only adopts `implementer`'s discipline, so a
  hook on the agent would never fire.
- **What Notion holds** (checked 2026-10-30): 36 feature rows, 35 `Done` and one `Backlog`,
  `F-META-016` "Bun TypeScript script runtime" (target `Later`).
- **The model to follow** is `/Users/v/lab/app-template`:
  - one folder per ticket, `docs/tickets/<YYYY-MM-DD-HHmm>_<slug>/`, holding `feature.md`,
    `architecture.md`, `plan.md` and `verification.md`, started from a template;
  - a roadmap file that is the only home of a ticket not yet started;
  - five `/ticket-*` skills the user types (`disable-model-invocation: true`), thin wrappers over
    the `mattpocock-skills` plugin (`grilling`, `domain-modeling`, `codebase-design`, `tdd`,
    `code-review`) that decide only paths and gates;
  - agents `implementer` (a `Stop` hook that runs the project check, with a `BLOCKED:` way out),
    `reviewer` (one review axis, read-only), `verifier`, `researcher`;
  - a human guide with a dependency map of what each skill and agent uses.
- **Plugins:** `mattpocock-skills` and `superpowers` are both installed for this user.
  `app-template` enables the first and disables the second per project, because `superpowers`'
  skills write plans to their own paths and compete with the ticket skills; in this session its
  start hook demanded its brainstorming skill before any work.
- **"Test" in a config repo** is `scripts/check.sh` green plus an observed keypress; there are no
  unit tests (`.claude/rules/testing.md`). A step's test-first therefore names a validator, a
  probe that must make it fail, or a keypress to reproduce.
- **Subagents cannot ask the user** (`AskUserQuestion` is unavailable to them), so grilling, plan
  review and commit approval run in the main session.
- **This ticket bootstraps itself:** the skills do not exist until it lands, so it runs the new loop
  by hand, with this file as its first artifact.

## Scope

- Ticket folders in the repo, started from a template; a roadmap file for tickets not started.
- Five user-invoked phase skills in place of the `/sdd:*` commands.
- Agents `implementer` (with the check gate), `reviewer`, `verifier`, `researcher`.
- `CLAUDE.md`, the rules, the PR template and the README rewritten for the new loop; every pointer
  to Notion as the home of specs removed.
- A guide for humans: how the loop runs, and the dependency map.

## Out of scope

- Moving Notion's history into the repo: the 35 done features stay in Notion, and old `Refs:`
  links keep resolving there.
- A plugin shared by both repos (Q3).
- `app-template`'s `/explain` skill and `explainer` agent; a roadmap entry can bring them later.
- Any change to the stack's own config (Ghostty, Zellij, Neovim, zsh).

## Requirements

### Artifacts

- **R1** — WHEN a change of substance starts, THE SYSTEM SHALL record its feature, architecture,
  plan and verification as Markdown files in one repository folder per ticket, named by the
  ticket's start time and slug.
- **R2** — WHILE a ticket has not started, THE SYSTEM SHALL hold it only as an entry in the roadmap
  file; WHEN it starts, THE SYSTEM SHALL replace the entry's status with a link to its folder.
- **R3** — WHEN a commit belongs to a ticket, THE SYSTEM SHALL name the ticket's folder in the
  commit's `Refs:`.
- **R4** — WHERE no Notion connector is configured, THE SYSTEM SHALL run every phase of the loop.

### Phases

- **R5** — WHEN the user types `/`, THE SYSTEM SHALL offer one command per phase (feature,
  architecture, plan, implement, verify), and SHALL NOT start a phase on the model's own initiative.
- **R6** — WHEN a phase needs the user's answer or approval, THE SYSTEM SHALL ask in the main
  session.
- **R7** — IF a plugin skill a phase uses would write an artifact outside the ticket folder (a plan
  file, a glossary, an ADR), THEN THE SYSTEM SHALL write it into the ticket folder instead.

### Implement

- **R8** — WHEN the implementer agent tries to finish a step while the stack check fails, THE
  SYSTEM SHALL send it back with the failing output, unless its final message starts with
  `BLOCKED:`.
- **R9** — WHEN a step's implementation is ready, THE SYSTEM SHALL present a review on two axes,
  Standards and Spec, and SHALL commit the step only after the user's explicit approval.
- **R10** — IF a requirement can only be shown by a keypress, THEN THE SYSTEM SHALL record the
  keypress and the observed result as its evidence.

### Verify

- **R11** — WHEN a ticket is verified, THE SYSTEM SHALL record a verdict per requirement, and the
  lessons that recurred in two or more steps, each with one proposed change to a skill, a rule or
  a check that is applied only on the user's OK.

### Cleanup

- **R12** — WHEN this ticket lands, THE SYSTEM SHALL name no `/sdd:` command and no Notion page or
  database as the home of features, tasks or research, in any file outside `docs/tickets/`.

## Acceptance

| Req | How to verify |
|---|---|
| R1 | At merge, this ticket's folder holds `feature.md`, `architecture.md`, `plan.md` and `verification.md`; the template folder holds the same four. |
| R2 | The roadmap file exists; its entry for this ticket links to this folder. |
| R3 | `git log origin/main..HEAD --format=%B \| grep '^Refs:'` — every line names `docs/tickets/2026-10-30-2031_sdd-in-git/`. |
| R4 | `git grep -n 'mcp__notion\|collection://' -- .claude` prints nothing; and `/ticket-feature` on a throwaway slug, in a session started with `--strict-mcp-config` and no MCP config, writes its `feature.md`. |
| R5 | Typing `/ticket` lists exactly the five phase skills; `grep -L 'disable-model-invocation: true' .claude/skills/ticket-*/SKILL.md` prints nothing. |
| R6 | No phase skill has `context: fork`; each skill's approval or grilling step is in its own body (read). |
| R7 | The throwaway run of R4 leaves no `docs/superpowers/`, `GLOSSARY.md`, `CONTEXT.md` or `docs/adr/`. |
| R8 | The hook script, fed a final message without `BLOCKED:` on a tree with a broken key, exits 2 and prints the check's failure; fed one that starts with `BLOCKED:`, exits 0; on a clean tree, exits 0. |
| R9 | Each step of this ticket's `plan.md` shows `Status: done` with its review findings, and its commit came after an approval in the session. |
| R10 | The verification template and the `verifier` agent each ask for the keypress and the observed result (read). |
| R11 | This ticket's `verification.md` has a verdict for R1–R12 and a **Lessons** section. |
| R12 | `git grep -nE '/sdd:\|app\.notion\.com\|Notion MCP' -- . ':!docs/tickets'` prints nothing; the `Brewfile`'s Notion cask stays, without the comment that calls Notion the SDD hub. |

## Open questions

### Q1 — The one open Notion feature

- **Why it matters:** `F-META-016` (Bun TypeScript script runtime, `Backlog`) is the only Notion
  item not done; once the loop leaves Notion, nothing in the repo would remember it.
- **Options:** A — copy it into the new roadmap as a planned entry, with a link to its Notion page;
  B — leave it only in Notion.
- **Recommendation:** A — the roadmap is meant to be the one list of what comes next.
- **Answer:** B, in a stronger form — nothing is carried over from Notion, not even this item; the roadmap starts empty of Notion entries (user, 2026-10-30).

### Q2 — The `superpowers` plugin in this project

- **Why it matters:** its skills start their own process (brainstorm → plan → execute) and write
  to their own paths; beside the ticket skills an agent gets two competing instructions.
- **Options:** A — disable it for this project in `.claude/settings.json` (`enabledPlugins`), as
  `app-template` does; it stays on in other projects. B — keep it on.
- **Recommendation:** A — the same choice `app-template` made, for the same reason.
- **Answer:** A — disabled for this project only (user, 2026-10-30).

### Q3 — Copy the toolkit, or share it

- **Why it matters:** the five skills and four agents would exist twice, in `app-template` and here,
  and drift apart again.
- **Options:** A — copy and adapt now (paths, the check command, keypress evidence), and add a
  roadmap entry to extract a shared plugin later; B — build the shared plugin first.
- **Recommendation:** A — a plugin needs a stable shape, and the config-repo variant is what shows
  which parts really are shared.
- **Answer:** A — copy and adapt now; a roadmap entry tracks the shared plugin (user, 2026-10-30).

### Q4 — Where the guide and the roadmap live

- **Why it matters:** `app-template` keeps them in `docs/knowledge/`; this repo's `docs/` is flat,
  with user-facing guides.
- **Options:** A — `docs/sdd.md` and `docs/roadmap.md`, beside the existing guides; B —
  `docs/knowledge/sdd.md` and `docs/knowledge/roadmap.md`, matching `app-template`'s paths.
- **Recommendation:** B — the same paths in both repos keep the copied skills identical apart from
  the stack-specific lines, which makes Q3's later plugin a straight extraction.
- **Answer:** B — `docs/knowledge/sdd.md` and `docs/knowledge/roadmap.md` (user, 2026-10-30).
