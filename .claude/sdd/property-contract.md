<!-- Generated from the Terminal Stack SDD hub §4 — https://app.notion.com/p/385fb28bd5f1810d91ddd69ea4c49243. Re-sync on change. -->

# Notion property contract (§4)

When a `/sdd:*` command creates rows via the Notion MCP, these field values are **not optional** —
they are the structured contract the rest of the loop relies on. A missing field is a defect.
Data-source IDs to create against live in `@.claude/sdd/data-sources.md`.

## Feature row (Features DB)

- **`Feature ID`** — `F-AREA-NNN` (sequential, no gaps; check the current max in the DB first).
- **`Title`** — short imperative form ("Autolock on focus loss", "Starship git prompt").
- **`Area`** — exactly one of: **Terminal · Multiplexer · Editor · Shell · Agent · Meta**.
  - **Terminal** = Ghostty · **Multiplexer** = Zellij · **Editor** = Neovim/LazyVim ·
    **Shell** = zsh/Starship · **Agent** = Claude Code integration ·
    **Meta** = repo/README/`.claude/`/CI.
- **`Priority`** — `P0` · `P1` · `P2` · `P3`.
- **`Status`** — starts `Backlog` → `Drafted` (after Specify) → `In design` (after Plan) →
  `In build` (during Implement) → `In review` (during Verify) → `Done`.
- **`Target release`** — `v1` · `v1.1` · `Later` · `Backlog`.
- **`PR`** — the GitHub pull-request URL (set once a PR exists; one click from spec to diff).

> No `Persona` and no `Linked specs` requirement on this project. These are **config** features,
> not product features — there are no user personas. A `Specs` relation is optional at most.

## Task row (Tasks DB)

- **`Title`** — imperative, single outcome, prefixed with the task number ("T03 — Add
  `keybind = ctrl+a>n` for new tab in `ghostty/config`").
- **`Type`** — `Feature work` · `Bug` · `Chore` · `Spike` · `Refactor`.
- **`Priority`** — `P0` · `P1` · `P2`.
- **`Status`** — starts `Not started`; → `In progress` when an agent picks it up; back to
  `Not started` if abandoned mid-session; → `Done` **only after** the AC is verified.
- **`Estimate`** — `XS` (≤30 min) · `S` (≤2 h) · `M` (≤1 day). **XS–M only** — an `L` splits, an
  `XL` is refused (it's a hidden mini-feature).
- **`Autonomy`** — `AFK` (agent implements + merges unattended) · `HITL` (needs a human decision or
  review first). Default `AFK`; mark `HITL` only for a real human gate.
- **`Feature`** — relation to exactly one Feature row.
- **`Blocks` / `Blocked by`** — wire the dependency graph; missing edges make the loop pick tasks
  out of order. Publish rows **blockers-first** so `Blocked by` can reference real task URLs.
- **`Covers ACs`** — text: the feature AC IDs this task satisfies (`AC-1, AC-3`).

## Body-level (not a property)

Every task body carries a **`Covers ACs:`** line mapping it to the feature's AC IDs (`AC-1, AC-3`),
so traceability survives outside the property panel. See `@.claude/sdd/task-template.md`.
