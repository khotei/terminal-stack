---
name: ticket-plan
description: "SDD 3/5: turn feature.md and architecture.md into a reviewed plan.md"
argument-hint: "<ticket folder>"
disable-model-invocation: true
---

Write the implementation plan for the ticket at `$ARGUMENTS`. **This is the heavy review**: later
steps only conform to the plan. Gates: `.claude/rules/sdd.md`.

## Steps

1. Read `feature.md` and `architecture.md`.
2. Cut the work into **vertical slices**, each one commit that leaves `bash scripts/check.sh` green
   and fits one fresh implementer session (≤ ~400 changed lines; deletions of whole files
   excluded).
3. Write `plan.md` from `docs/tickets/_template/plan.md`, opening with its **Status** table, one
   row per step. Every step has:
   - **Delivers**: what the user can press, see or run differently once it lands, in plain words,
     no ids;
   - **Goal** with the `R…` and `D…` ids it serves;
   - **Blocked by:** the steps it needs, or `none`. Steps without a path between them are
     independent;
   - **Files**, including every `README.md`, cheatsheet and doc that names a key or path the step
     changes (grep for it);
   - **Test first**: the Seam from `architecture.md` and how it goes red first — the validator and
     the input that fails it, the probe, or the keypress and its expected result — or
     `config only`;
   - **Verify**: commands with their expected output, and keypresses for the user;
   - **Model**: `opus medium` for a move, rename, doc or plain config step, `opus high` for a step
     that writes a script, a hook or cross-tool behaviour; `/ticket-implement` spawns the
     implementer on it;
   - **Status:** `todo`.
4. **Check** the plan: spawn `researcher` once, with three lists.
   - **Exists**: every existing file path, config key, flag or tool a step names; paths the plan
     creates are left out. Each comes back `confirmed` against the installed version, or `wrong`
     with evidence and the correct value.
   - **Conforms**: every literal a step fixes (a key, a keybind, a file name), with the tool it
     lands in. Each comes back `conforms`, or with the line (`path:line`) it breaks in
     `.claude/rules/*.md`, or the key it collides with in another keyboard layer.
   - **Can fail**: every Verify and acceptance command, run once on the tree as it stands and once
     on a probe that must make it fail. A command that cannot fail, or fails for another reason,
     comes back with the fix (macOS `grep` and `git grep -E` ignore `\b`: use `-w`).
   Fix every finding in `plan.md` before presenting it. The report stays in the conversation;
   `plan.md` records no check.
5. End with a coverage table that maps every `R…` to at least one step.
6. Present the plan and iterate until the user approves it. Next comes
   `/ticket-implement <ticket folder>`.

Commit only on the user's explicit OK.
