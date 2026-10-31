# terminal-stack

`khotei/terminal-stack` — a public, terminal-first dev environment as config. There is **no
application code**; the "code" is config files for five tools that wire into one workflow:

- **Terminal** — Ghostty (`ghostty/config`, `key = value`)
- **Multiplexer** — Zellij (`zellij/config.kdl`, KDL + layouts)
- **Editor** — Neovim / LazyVim (`nvim/`, Lua + lazy.nvim)
- **Shell** — zsh + Starship (`zsh/.zshrc`, `*.zsh`, `starship.toml`)
- **Agent** — Claude Code (`.claude/`), running in a multiplexer pane

Layout is by tool, mirroring `~/.config` (`@.claude/rules/naming.md`).

## How work happens — the ticket loop

A change of substance is a ticket: one folder in `docs/tickets/` holding its feature, architecture,
plan and verification, written by five skills the user types in order —
**`/ticket-feature` → `/ticket-architecture` → `/ticket-plan` → `/ticket-implement`** (once per
step) **→ `/ticket-verify`**. A ticket not started yet is only an entry in
`docs/knowledge/roadmap.md`; a typo, a version bump or a doc fix needs no ticket. The gates are in
`.claude/rules/sdd.md`; the guide, with the dependency map and troubleshooting, is
`docs/knowledge/sdd.md`.

## Golden rules

1. **Never invent a config key.** Every key/keybind/Lua option/shell setting must be citable upstream
   (ghostty.org · zellij.dev · lazyvim.org · neovim.io · starship.rs) and present in the installed
   version. If you can't cite it, it's a `[TBD]`, not a guess. (`@.claude/rules/config.md`)
2. **Configs must validate.** A change isn't done until it loads — run `/check`, which runs
   `scripts/check.sh`, the one list of validators.
3. **No keybinding collisions** across the three keyboard layers — Ghostty keys, Zellij mode keys, nvim
   leader must not shadow each other.
4. **Every PR is a reference guide** — annotated per-setting rationale, how to try it, the
   keybinding cheatsheet, and the ticket's requirement mapping (`@.claude/rules/pull-requests.md`).

## Rules

Each rule loads on its own when a file under its `paths:` is read; `commits.md` loads always.
Open the one a task needs when no matching file is read yet (a PR touches no `.github/` file):

- `@.claude/rules/tech-stack.md` — the five tools + companion CLIs + the keyboard-layer contract.
- `@.claude/rules/config.md` — cross-tool config conventions (never-invent, one-file-owns-one-concern).
- `@.claude/rules/testing.md` — validation: how each tool's config is proven to load.
- `@.claude/rules/tooling.md` — Homebrew install + the validators/formatters.
- `@.claude/rules/naming.md` — folder/file layout per tool.
- `@.claude/rules/commits.md` · `@.claude/rules/pull-requests.md` — commit + PR format.
- `@.claude/rules/comments.md` · `@.claude/rules/claude-md.md` — what earns a comment / a doc line.
- `@.claude/rules/sdd.md` — the ticket loop's gates: artifacts, evidence at the Seams, rounds, approval.

## Maintaining these docs

A `CLAUDE.md`/rule caches what the **config cannot say** — the *why*, not the *what*. If a rebind
forces a doc edit, the doc was holding *what*; move it back to the config. Refresh only when a real
change lands, then run `/check`. (`@.claude/rules/claude-md.md`)
