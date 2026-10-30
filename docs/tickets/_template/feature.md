# <Title>

> Ticket: `<YYYY-MM-DD-HHmm>_<slug>` · Source: <link or "conversation">
> Related: [architecture.md](./architecture.md) · [plan.md](./plan.md)

## Problem

<What is wrong or missing today, and for whom, from their side: what they press, see or wait for.
Two to four sentences.>

## Goal

<What changes for them once the ticket lands, and why now. Two to four sentences.>

## Context

<What exists today that the reader needs: the current config and its behaviour, the installed
versions, constraints, related tickets. Facts carry the date they were checked. Terms come from
`docs/knowledge/glossary.md`.>

## Scope

- <capability in scope>

## Out of scope

- <adjacent capability left out, and where it goes instead>

## Requirements

<EARS only. One behaviour per requirement; group them under `###` headings when there are many.
A requirement states behaviour or an observable result — what a keypress does, what a command
prints, what loads — never a config key or a path: those go to `plan.md › Files`, and a check
below may name a command or a key.>

- **R1** — WHEN <trigger>, THE SYSTEM SHALL <response>.
- **R2** — IF <unwanted condition>, THEN THE SYSTEM SHALL <response>.
- **R3** — WHILE <state>, THE SYSTEM SHALL <response>.

## Acceptance

| Req | How to verify |
|---|---|
| R1 | <command and its expected output, or keypress → expected result, or the file to read> |

## Open questions

<For `/ticket-architecture`. Ask it so "yes" accepts the recommendation, or openly where there is
room to decide. Delete the section when empty.>

### Q1 — <question>

- **Why it matters:** <one line>.
- **Options:** A — <consequence>; B — <consequence>.
- **Recommendation:** <A, and why>.
- **Answer:** <filled when settled, naming the D… or R… it became>
