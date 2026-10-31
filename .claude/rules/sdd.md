---
paths:
  - "docs/tickets/**"
  - "docs/knowledge/roadmap.md"
  - ".claude/skills/**"
---

# Spec-driven development

Every change of substance runs **feature → architecture → plan → implement → verify** through the
`/ticket-*` skills. The procedures live in the skills; this file holds the constraints they share.
The guide for people is `docs/knowledge/sdd.md`.

## Artifacts

`docs/tickets/<YYYY-MM-DD-HHmm>_<slug>/`, started from `docs/tickets/_template/`:

| File | Holds | Written by |
|---|---|---|
| `feature.md` | problem, goal, context, scope, out of scope, requirements `R…` in EARS, acceptance per requirement, open questions | `/ticket-feature` |
| `architecture.md` | structure, contracts, **Seams**, decisions `D…` with the rejected alternative, risks | `/ticket-architecture` |
| `plan.md` | a status table; steps with `Delivers`, `Goal`, `Blocked by`, `Files`, `Test first`, `Verify`, `Model`, `Status`, findings; a coverage table | `/ticket-plan`, `/ticket-implement` |
| `verification.md` | verdict per requirement with its evidence, review, simplifications, **Lessons** | `/ticket-verify` |

- **A ticket that has not started exists only as an entry in `docs/knowledge/roadmap.md`.**
  `/ticket-feature <slug>` starts from that entry when one exists and replaces its status with a
  link to the ticket folder.
- `docs/knowledge/` holds the living how-it-works docs. Update them in the commit that changes the
  behaviour they describe.

## Gates

- **Requirements are EARS** (`WHEN … THE SYSTEM SHALL …`; also `WHILE`, `WHERE`, `IF … THEN`) and
  name behaviour (what a keypress does, what a command prints, what loads), not keys or paths.
- **Evidence sits at the Seams** agreed in `architecture.md`. A step's *Test first* names one: a
  validator in `scripts/check.sh` and the input that turns it red, a probe that fails before the
  step and passes after, a keypress with the result expected, or `config only`, which then rests
  on its *Verify* commands.
- **Evidence is observed, never asserted:** a command and its output, `path:line`, or
  *keypress → observed result*. A keypress is pressed by the user; an agent states the key and the
  result to expect.
- **The heavy review lands once, on the plan.** Steps then conform to it.
- **One plan step = one approved commit per round**; the step is ≤ ~400 changed lines (whole-file
  deletions excluded), fits one fresh session, and leaves `bash scripts/check.sh` green. A ticket
  is one branch `<type>/<slug>` and one squash-merged PR.
- **A step lands in rounds, one commit each.** The implementer's pass is round `S3.1`; before a
  recommendation of the user's is applied, the main session offers to commit what stands, and the
  recommendation lands as `S3.2`, so each diff is read alone. The commit body opens with the round
  id and what it changed; `plan.md` is edited only at the last round.
- **Approval gate.** After each step: the implementer's report, the two-axis review, then the
  user's explicit OK before any commit or amend. Pushing or opening a PR needs its own OK.
- **Deviations are recorded** in the same commit: `plan.md` findings, `architecture.md ›
  Decisions` when it is a decision, and `feature.md` when it changes what a requirement asks.
