---
description: "Phase 3 (Plan): write the architecture Plan (config decomposition + validation strategy) onto the feature page"
argument-hint: "F-AREA-NNN"
context: fork
agent: planner
---

<!-- Generated from the Terminal Stack SDD hub §7.4 (+ §6.3 template) — https://app.notion.com/p/385fb28bd5f1810d91ddd69ea4c49243. Re-sync on change. -->

You are running **Phase 3 (Plan)** of the Terminal Stack SDD hub on `$ARGUMENTS`.

**Embedded — do NOT fetch from Notion:** the plan template `@.claude/sdd/plan-template.md` and the
data-source IDs `@.claude/sdd/data-sources.md`.
**Fetch live:** the feature spec (the page body), the upstream doc sections it cites, and the
existing config in `ghostty/`, `zellij/`, `nvim/`, `zsh/` that grounds the plan.

> **Review moves left.** The plan is the cheapest, highest-leverage place to catch a mistake — a
> wrong plan multiplies into N wrong tasks. If the feature's shape is unknown or it touches a large
> existing surface, run a throwaway **recon spike** first (a `Spike` task — read-only exploration to
> find the seam), then plan from what you learned, and treat the plan as revisable. See the
> `@.claude/sdd/plan-template.md` notes.

## Steps

1. **Re-read the feature spec** (`$ARGUMENTS`) end to end — goal, scope, ACs, the `Reflects:`
   pointer.
2. **Produce the plan** using `@.claude/sdd/plan-template.md`. The **Config decomposition** (which
   file owns what; keybindings kept non-colliding; never invent a config key — cite the upstream
   doc beside each) and the **Validation strategy** (how each touched config is proven to load via
   `@.claude/commands/check.md`, what's deliberately left unvalidated) are mandatory.
3. **Cite the upstream doc** behind every config key. A key **not yet** found in the upstream docs →
   prefix it **`proposal:`** and confirm it exists before Phase 4.
4. **Sequence the work** into ordered steps — each step becomes exactly one Phase-4 task. Aim for
   5–15 steps; >20 means the feature is too big — say so and recommend a split.
5. **Write the plan into a collapsible "Plan" toggle** inside the Notion feature page (Notion MCP;
   consult `notion://docs/enhanced-markdown-spec` for toggle syntax if unsure). Set the feature
   **`Status = In design`**.
6. **End with one line:** `Plan drafted for $ARGUMENTS. New config proposals to confirm: <list | none>. Next: /sdd:tasks $ARGUMENTS.`

## Do not

- Do **not** write config. (It's denied to you by tool policy anyway.)
- Do **not** invent a config key — if it isn't in the upstream docs, flag it `proposal:`.
- Do **not** create task rows — that's Phase 4 (`/sdd:tasks`). Stop at the ordered step list.
- Do **not** fetch the plan template / data-source IDs from Notion — they're embedded above.
