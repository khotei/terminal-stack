<!-- Generated from the Terminal Stack SDD hub §6.3 — https://app.notion.com/p/385fb28bd5f1810d91ddd69ea4c49243. Re-sync on change. -->

# Plan template (§6.3)

What `/sdd:plan` writes into the **Plan** toggle inside the feature page. The two load-bearing
sections are **Config decomposition** (which file owns what, and how the keys/keybinds are kept
non-colliding and idempotent) and **Validation strategy** — don't drop them.

```markdown
# Plan — F-NNN <title>

## Goal recap
(One sentence — what success looks like for this feature.)

## Stack sketch
- Tools touched (Ghostty / Zellij / Neovim / zsh+Starship / Claude Code) and which file each lives in.
- New config surfaces introduced.
- Diagram (mermaid or ASCII) of how the tools interact, if non-trivial (e.g. prefix-key routing).

## Config decomposition
- List the config files to create or modify. For each, say what it owns and what it must NOT touch.
- Keep each file the single source of one concern (e.g. all Ghostty keybinds in `ghostty/config`, not scattered).
- Flag every config key against its upstream doc — never invent a key. Note the doc URL beside each non-trivial key.
- Keybinding / prefix-key map: show that the new bindings do not collide with the multiplexer prefix or the editor leader.

## Key/keybind deltas
- New config keys / KDL nodes / Lua plugin spec / aliases (with the exact value and the upstream doc).
- Idempotency / reload plan (does the tool hot-reload, or does it need a restart / `:Lazy sync` / `source ~/.zshrc`?).

## Sequencing
1. Step 1 (becomes Task T-NNN-001)
2. Step 2 (becomes Task T-NNN-002)
... each step is one task.

## Validation strategy
- How each touched config is proven to load: `ghostty +show-config`, `zellij setup --check`,
  `nvim --headless "+checkhealth" +qa` (or `nvim --headless -c 'luafile <file>' -c qa`), `zsh -n <file>`,
  and `stylua --check` / `shfmt -d` where formatters apply. See `@.claude/commands/check.md`.
- Which surfaces are validated by command vs by a visible keypress the verifier must observe.
- What is deliberately left unvalidated, and why.

## Risks
| Risk | L | I | Mitigation |
|---|---|---|---|

## Out of scope (for this plan)
- ...
```

## Terminal Stack notes

- **The plan is where review is cheapest and most leveraged** — scrutinise it *here*, before any
  config exists. A wrong plan multiplies into N wrong tasks; a bad keybind caught in the plan costs
  one edit, caught after Phase 5 it costs a rebind across every keyboard layer.
- **Treat the plan as a hypothesis, not a frozen script.** When the feature's shape is unknown or it
  lands in a large existing/legacy surface, precede planning with a throwaway **recon spike** — a
  read-only (or delete-the-branch) exploration, filed as a `Spike` task
  (`@.claude/sdd/property-contract.md`) — to map the real dependencies and find the seam, *then*
  write the plan from what you learned. Fold `/sdd:implement` and `/sdd:verify` findings back into the
  still-unbuilt tail rather than executing a stale plan.
- **Legacy surfaces: find the seam, don't design one.** On the application repos this toolkit plans
  for, the insertion point in existing code is *found* (the least-bad seam), not freshly designed,
  and the first contract is a **characterization test** pinning current behaviour before the change
  (Feathers, *Working Effectively with Legacy Code* — established practice). terminal-stack itself
  has no legacy app surface — this is guidance the plan carries for those repos.
- **Cite the upstream doc** behind every config key (`ghostty.org`, `zellij.dev`, `lazyvim.org`,
  `neovim.io`, `starship.rs`). Ground each choice in the existing config in `ghostty/`, `zellij/`,
  `nvim/`, `zsh/` where one exists to imitate.
- **New config not yet documented upstream → prefix `proposal:`** in the plan and confirm the key
  exists before Phase 4 (`/sdd:tasks`). A `proposal:` must be approved before tasks are written; an
  invented key is never a settled decision.
- **Sequencing aims for 5–15 steps.** >20 steps means the feature is too big — split it. Each step
  becomes exactly one task in Phase 4.
- **Do not create task rows here** — that's `/sdd:tasks`. The plan stops at the ordered step list.
