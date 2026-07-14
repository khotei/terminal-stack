<!-- Generated from the Terminal Stack SDD hub §6.2 — https://app.notion.com/p/385fb28bd5f1810d91ddd69ea4c49243. Re-sync on change. -->

# Task row template (§6.2)

The body `/sdd:tasks` writes into each Tasks-DB row. It is what Claude Code sees when it picks up
the task in a fresh `/sdd:implement` session — self-contained but tight. The Notion `Title`
property is imperative, single-outcome, prefixed with the task number (e.g. *T07 — Bind `Alt+d` to
toggle Zellij's Locked mode in `config.kdl`*).

```markdown
> **Feature:** <mention parent Feature page>
> **Source:** <mention hub section / upstream doc> §<section> *(<section title>)*
> **Autonomy:** AFK | HITL — AFK = implement + merge unattended; HITL = needs a human decision or review first (prefer AFK).
> **Covers ACs:** <feature AC IDs this task satisfies, e.g. AC-1, AC-3>
> **Slice:** vertical (cuts through every layer it touches; demoable on its own) | horizontal (single layer — foundational work only)
> **Upstream doc (optional):** <link>

## Context
One paragraph. Why this task exists in the feature's task chain. What it builds on (dependencies); what depends on it. Anchors the agent before it starts editing config.

## Goal
One sentence. The single observable outcome. *"`ghostty +show-config` lists the new keybind with no errors"*, *"`zellij setup --check` passes after adding the plugin"*, *"opening nvim shows the new statusline"*. If you need a comma, you have two goals — split the task.

## What to do
1. <Imperative step. Name the config file or surface it touches; include the exact key/KDL/Lua/shell line inline. Never invent a config key — cite the upstream doc.>
2. <Next imperative step.>
3. ...

## Files to create
- ghostty/config (or zellij/config.kdl, nvim/lua/…, zsh/.zshrc, …)
- ...
(Or **Files to touch** if the task modifies existing files. List explicit paths; do not say "see folder X".)

## Acceptance criteria
- [ ] <AC verifiable by running a validator (`/check`), or by observing a keypress / visible behavior.>
- [ ] <AC...>
- [ ] Config still validates via `/check` (Ghostty/Zellij/nvim/zsh as applicable).
- [ ] Cheatsheet / README row added if the change adds a keybinding or alias a user must know.
- [ ] Spec change-log row added if implementation revealed a behaviour change.

## Notes & gotchas
- <Anti-pattern to avoid (e.g. "don't bind `ctrl+a` in Ghostty — it's Zellij's prefix; pick a non-colliding key").>
- <Subtle constraint from the hub / upstream doc the agent might miss (e.g. Ghostty needs a reload; nvim plugin needs `:Lazy sync`).>
- <Decision deferred to a later task + rationale.>
```

## Sizing & autonomy (Terminal Stack)

- **Estimate** is **XS–M only** — `XS` ≤30 min · `S` ≤2 h · `M` ≤1 day. An `L` task splits; an
  `XL` is refused (it's a hidden mini-feature).
- A task is correctly scoped when it ships in **one** `/sdd:implement` session with a **single
  verifiable outcome**. Bigger → split; smaller → merge.
- Tag **Autonomy** `AFK` by default; `HITL` only for a real human gate (a keybinding scheme that
  changes muscle memory, a destructive dotfile move, an irreversible config migration). See
  `@.claude/sdd/property-contract.md`.
