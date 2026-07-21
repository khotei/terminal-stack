---
description: "Phase 4 (Tasks): split the Plan into Autonomy-tagged kanban rows (after you approve the breakdown)"
argument-hint: "F-AREA-NNN"
---

<!-- Generated from the Terminal Stack SDD hub §7.5 (+ §6.2 template, §4 contract) — https://app.notion.com/p/385fb28bd5f1810d91ddd69ea4c49243. Re-sync on change. -->

You are running **Phase 4 (Tasks)** of the Terminal Stack SDD hub on `$ARGUMENTS`.

**Adopt the task-splitter discipline** (`@.claude/agents/task-splitter.md`): vertical tracer-bullet
slices, XS–M only, no config writes, approval before rows.

> **This phase runs in the main context — NOT a forked subagent.** Step 3 presents the breakdown and
> iterates to *your* approval, which a subagent can't do. See `@.claude/rules/sdd.md` (fork map).

**Embedded — do NOT fetch from Notion:** the task template `@.claude/sdd/task-template.md`, the
property contract `@.claude/sdd/property-contract.md`, and the data-source IDs
`@.claude/sdd/data-sources.md` (the Tasks collection id lives there).
**Fetch live:** the feature's Plan toggle + acceptance criteria (the page body).

> **Tasks conform to the plan's contract surface.** The plan's Config decomposition + Key/keybind
> deltas are the reviewed-once skeleton; each slice fills one part of it. **The AC checklist is that
> slice's contract** — the task's slice of the surface — a runnable check the implementer commits
> *before* the fill (in this config repo, `/check` plus the observable keypress). Per-task review is
> therefore **conformance** ("does this slice match the agreed keys/binds?"), not re-litigating the
> design. Keep each slice XS–M **and** its diff reviewable (`<~400 LOC`). See
> `@.claude/sdd/task-template.md`.

## Steps

1. **Read the feature's Plan + ACs** (`$ARGUMENTS`). Each plan step maps to one or more tasks.
2. **Draft vertical tracer-bullet slices** by default — each cuts through every layer it touches
   (config key → keybind → cheatsheet/README → validator) and is demoable on its own. Prefer many
   thin slices. Horizontal (single-layer) tasks only for foundational work where a vertical slice is
   impossible.
3. **Present the breakdown FIRST** as a numbered list — *title · Autonomy · Estimate · Blocked-by ·
   Covers ACs* — and ask whether granularity, dependencies, and AFK/HITL splits are right. **Iterate
   until the user approves. Do not write any rows yet.**
4. **On approval, create one Task row per slice** in the Tasks DB (data-source id from
   `@.claude/sdd/data-sources.md`), **publishing blockers-first** so each `Blocked by` references a
   real task URL (Notion mirrors the reciprocal `Blocks`). Use `@.claude/sdd/task-template.md` for
   the body and include a `Covers ACs:` line mapping the task to the feature's AC IDs.
5. **Set every required field** per `@.claude/sdd/property-contract.md`: `Title` (`T0N — …`,
   imperative, single outcome), `Type`, `Priority`, `Status = Not started`, `Estimate` (**XS–M
   only** — `L` splits, `XL` refuses), `Autonomy` (`AFK`/`HITL`), `Feature` relation, `Covers ACs`,
   and `Blocks`/`Blocked by` edges.
6. **Validate:** every plan step maps to ≥1 slice; every task has a single demoable outcome, a
   `Covers ACs:` line, an Autonomy tag, and no `L`/`XL` estimate.
7. **End with one line:** `Tasks created: <N> (AFK <n> / HITL <m>). Critical path: T0a → T0b → … Next: /sdd:implement <first unblocked AFK>.`

## Do not

- Do **not** create any row before the user approves the breakdown.
- Do **not** write config, or use `L`/`XL` estimates.
- Do **not** fetch the template / contract / data-source IDs from Notion — they're embedded above.
