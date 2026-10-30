# <Title> — plan

> Ticket: `<YYYY-MM-DD-HHmm>_<slug>` · Requirements: [feature.md](./feature.md) · Design: [architecture.md](./architecture.md)

## Status

<One row per step, updated in each step's commit, so the reader sees the ticket's state without
reading the steps; `git log` holds each step's commit.>

| Step | Delivers | Status |
|---|---|---|
| S1 | <the step's Delivers, in a few words> | todo |

## How to run this plan

- Branch `<type>/<slug>`; one commit per step, after the user's OK (`/ticket-implement`).
- Each step leaves `bash scripts/check.sh` green and fits one fresh session (≤ ~400 changed
  lines).
- A deviation is recorded in the step's findings, and in `architecture.md › Decisions` when it is a
  decision.

## Steps

#### S1 — <title>

- **Delivers:** <two to four plain lines: what the user can press, see or run differently once the
  step lands, without ids>.
- **Goal:** <outcome> (R1, D1).
- **Blocked by:** none.
- **Files:** <paths, including every README and cheatsheet that names a changed key>.
- **Test first:** <seam from architecture.md> — <the validator and the input that turns it red, the
  probe that must fail first, or the keypress and its expected result>. Or `config only`.
- **Verify:** <commands with their expected output; keypress → expected result, checked by hand>.
- **Model:** <model and effort, e.g. `opus medium`>
- **Status:** todo

## Requirement coverage

| Req | Steps |
|---|---|
| R1 | S1 |
