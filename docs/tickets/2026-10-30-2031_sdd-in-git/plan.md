# SDD in git — plan

> Ticket: `2026-10-30-2031_sdd-in-git` · Requirements: [feature.md](./feature.md) · Design: [architecture.md](./architecture.md)

## Status

| Step | Delivers | Status |
|---|---|---|
| S1 | ticket templates and the roadmap | done |
| S2 | the four agents and the implementer's check gate | done |
| S3 | the five phase skills, `/check` as a skill, the plugin settings | todo |
| S4 | the guide, the SDD rule and `CLAUDE.md` for the new loop | todo |
| S5 | commit, PR and doc rules speak of tickets, not Notion | todo |
| S6 | the old toolkit and every Notion pointer removed | todo |

## How to run this plan

- Branch `chore/sdd-in-git`; one commit per step, after the user's OK.
- **S1–S3 run by hand** in the main session, since the skills and agents do not exist yet; the
  main session then plays the implementer and presents the diff for approval. **From S4 on**, the
  user types `/ticket-implement docs/tickets/2026-10-30-2031_sdd-in-git/` (in a new session if
  the skills are not listed yet), which exercises the gate live.
- Each step leaves `bash scripts/check.sh` green and stays under ~400 changed lines (deletions in
  S6 excluded).
- A deviation is recorded in the step's findings, and in `architecture.md › Decisions` when it is
  a decision.

## Steps

#### S1 — Ticket templates and the roadmap

- **Delivers:** a new ticket starts from four templates that ask for config-repo evidence
  (validators, probes, keypresses) instead of tests; a roadmap file lists what comes next.
- **Goal:** the artifact shapes every later phase writes (R1, R2, R10, R11; D5).
- **Blocked by:** none.
- **Files:** `docs/tickets/_template/{feature,architecture,plan,verification}.md` (new),
  `docs/knowledge/roadmap.md` (new: how an entry flows; entries for this ticket, linked to its
  folder, and for the shared plugin of Q3).
- **Test first:** config only.
- **Verify:** `ls docs/tickets/_template/` lists the four files; `grep -n 'keypress'
  docs/tickets/_template/{plan,verification}.md` finds the evidence field in both;
  `grep -n '2026-10-30-2031_sdd-in-git' docs/knowledge/roadmap.md` finds the link;
  `bash scripts/check.sh` green.
- **Model:** `opus medium`
- **Status:** done
- **Findings:** the plan template's *Files* also asks for every README and cheatsheet that names a changed key — this repo's usual drift (a rebind leaves the README behind).

#### S2 — Agents and the check gate

- **Delivers:** `implementer` works one plan step in a fresh context and cannot finish while the
  stack check is red unless it reports `BLOCKED:`; `reviewer` judges one review axis read-only;
  `verifier` and `researcher` read tickets from the repo instead of Notion.
- **Goal:** R8, R9, R10; D3, D4.
- **Blocked by:** S1.
- **Files:** `.claude/hooks/check.sh` (new), `.claude/agents/reviewer.md` (new),
  `.claude/agents/{implementer,verifier,researcher}.md` (rewritten from `app-template`'s, per D5).
- **Test first:** `.claude/hooks/check.sh` fed JSON on stdin — with a probe file holding `(T01)`
  in the tree and a final message without `BLOCKED:`, it must exit 2 and print the check's
  failure; it does not exist yet, so the run fails first.
- **Verify:**
  - `printf '{"last_assistant_message":"done","cwd":"%s"}' "$PWD" | .claude/hooks/check.sh`
    with the probe present → exit 2 and the provenance failure on stderr; without the probe → 0;
  - the same with `"BLOCKED: x"` and the probe present → 0;
  - `"cwd":"/nonexistent"` → exit 2 and the "cannot find" message;
  - `grep -n 'timeout' .claude/agents/implementer.md` shows `600`; `grep -c 'Notion'
    .claude/agents/{implementer,verifier,researcher,reviewer}.md` prints 0 for each;
  - `bash scripts/check.sh` green, probe deleted.
- **Model:** `opus high`
- **Status:** done
- **Findings:** `implementer` does not preload `mattpocock-skills:tdd`, unlike `app-template`'s: that skill drives toward unit tests, while a step here proves itself with a validator, a probe or a keypress, which the agent's own *Evidence first* line states. The hook passes all five cases: probe → 2, `BLOCKED:` → 0, lost `cwd` → 2, clean → 0, a sub-folder `cwd` → 0.

#### S3 — Phase skills, `/check` and plugin settings

- **Delivers:** typing `/ticket` offers five phases that only the user starts; each writes into
  the ticket folder, overrides the plugin's paths, and asks the user in the main session;
  `/check` keeps working as a skill; `superpowers` is off and `mattpocock-skills` on for this
  repo.
- **Goal:** R4, R5, R6, R7, R9, R11; D1, D2, D5, D6.
- **Blocked by:** S2.
- **Files:** `.claude/skills/ticket-{feature,architecture,plan,implement,verify}/SKILL.md` (new),
  `.claude/skills/check/SKILL.md` (moved from `.claude/commands/check.md`, which is deleted),
  `.claude/settings.json`.
- **Test first:** config only.
- **Verify:** `grep -L 'disable-model-invocation: true' .claude/skills/ticket-*/SKILL.md` prints
  nothing; `grep -l 'context: fork' .claude/skills/*/SKILL.md` prints nothing; `grep -rnwE
  'make check|bun|Biome|tsc' .claude/skills/ticket-*` prints nothing (`-w`, not `\b`: BSD grep
  and macOS `git grep` treat `\b` differently, `c019db9`); `jq .enabledPlugins
  .claude/settings.json` shows both entries; in a new session, typing `/ticket` lists the five
  skills and `/check` runs the script; `bash scripts/check.sh` green.
- **Model:** `opus medium`
- **Status:** todo

#### S4 — Guide, SDD rule and `CLAUDE.md`

- **Delivers:** a human guide explains the loop, when to run which cycle, the dependency map and
  troubleshooting; the SDD rule holds only the gates; `CLAUDE.md` sends a session to the skills
  and no longer requires Notion.
- **Goal:** R4, R6, R11; D2, D5.
- **Blocked by:** S3.
- **Files:** `docs/knowledge/sdd.md` (new), `.claude/rules/sdd.md` (rewritten, `paths:` on
  `docs/tickets/**`, `docs/knowledge/roadmap.md`, `.claude/skills/**`), `.claude/CLAUDE.md`.
- **Test first:** config only.
- **Verify:** the dependency map in `docs/knowledge/sdd.md` names exactly the skills in
  `.claude/skills/` and the agents in `.claude/agents/` (compare with `ls`); `grep -n 'Notion'
  .claude/CLAUDE.md .claude/rules/sdd.md` prints nothing; `wc -l .claude/rules/sdd.md` ≤ 80;
  `bash scripts/check.sh` green.
- **Model:** `opus medium`
- **Status:** todo

#### S5 — Commit, PR and doc rules

- **Delivers:** a commit names its ticket folder in `Refs:` and its slug as scope; a PR body maps
  to the ticket's requirements instead of a Notion feature; the doc rules point at skills and the
  guide.
- **Goal:** R3, R12; D1, D7.
- **Blocked by:** S4.
- **Files:** `.claude/rules/{commits,pull-requests,claude-md,config,testing}.md`,
  `.claude/agent-patterns/commit-examples.md`, `.github/PULL_REQUEST_TEMPLATE.md`.
- **Test first:** config only.
- **Verify:** `git grep -nE '/sdd:|app\.notion\.com|Notion' -- .claude/rules .claude/agent-patterns
  .github` prints nothing; `bash scripts/check.sh` green.
- **Model:** `opus medium`
- **Status:** todo

#### S6 — Remove the old toolkit and the Notion pointers

- **Delivers:** nothing of the Notion-bound loop is left: no `/sdd:` command, no bundle, no
  Notion-only agents; the README, the guide index, the Claude Code README and the `Brewfile`
  describe the new loop or say nothing about Notion's role in it.
- **Goal:** R12; D1, D2, D7.
- **Blocked by:** S5.
- **Files:** delete `.claude/commands/` and `.claude/sdd/`, `.claude/agents/{spec-author,planner,task-splitter}.md`;
  edit `README.md` (§ How this repo is built), `docs/guide.md` (its pointer to the commands),
  `claude/README.md` (the Notion MCP row), `Brewfile` (the comments on `gh` and `notion`).
- **Test first:** the R12 grep — `git grep -nE '/sdd:|app\.notion\.com|Notion MCP' -- .
  ':!docs/tickets'` prints hits before the step and nothing after.
- **Verify:** that grep empty; `ls .claude/commands .claude/sdd` fails; `ls .claude/agents` lists
  `implementer`, `researcher`, `reviewer`, `verifier`; `bash scripts/check.sh` green.
- **Model:** `opus medium`
- **Status:** todo

## Requirement coverage

| Req | Steps |
|---|---|
| R1 | S1 (templates); this folder |
| R2 | S1 |
| R3 | S5; every commit of this ticket |
| R4 | S3, S4, S6 |
| R5 | S3 |
| R6 | S3, S4 |
| R7 | S3 |
| R8 | S2 |
| R9 | S2, S3; S4–S6 run through it |
| R10 | S1, S2 |
| R11 | S1, S3, S4 |
| R12 | S5, S6 |
