# terminal-stack

`khotei/terminal-stack` — a public, terminal-first dev environment as config. There is **no
application code**; the "code" is config files for five tools that wire into one workflow:

- **Terminal** — Ghostty (`ghostty/config`, `key = value`)
- **Multiplexer** — Zellij (`zellij/config.kdl`, KDL + layouts)
- **Editor** — Neovim / LazyVim (`nvim/`, Lua + lazy.nvim)
- **Shell** — zsh + Starship (`zsh/.zshrc`, `*.zsh`, `starship.toml`)
- **Agent** — Claude Code (`.claude/`), running in a multiplexer pane

Layout is by tool, mirroring `~/.config` (`@.claude/rules/naming.md`). `specs/` is **not** on disk —
feature/task state is Notion-only.

## How work happens — the SDD loop

Every change runs through Spec-Driven Development against Notion:

`research?` → **specify → clarify → plan → tasks → implement → verify**

The `/sdd:*` commands live in `@.claude/commands/` (index: `@.claude/commands/README.md`); the build
contract is `@.claude/rules/sdd.md`. The live Feature/Task rows and Research pages are in this
project's Notion (data-source IDs: `@.claude/sdd/data-sources.md`).

## Golden rules

1. **Notion MCP must be connected** — the SDD commands read/write Notion. No `.mcp.json` is committed
   (public repo, per-machine connector); connect your own.
2. **Never invent a config key.** Every key/keybind/Lua option/shell setting must be citable upstream
   (ghostty.org · zellij.dev · lazyvim.org · neovim.io · starship.rs). If you can't cite it, it's a
   `[TBD]`, not a guess. (`@.claude/rules/config.md`)
3. **Configs must validate.** A change isn't done until it loads — run `/check`
   (`@.claude/commands/check.md`): `ghostty +show-config`, `zellij setup --check`,
   `nvim --headless …`, `zsh -n`.
4. **No keybinding collisions** across the three keyboard layers — Ghostty keys, Zellij prefix, nvim
   leader must not shadow each other.
5. **Every PR is a reference guide** — annotated per-setting rationale, how to try it, the
   keybinding cheatsheet, and the Feature/AC mapping (`@.claude/rules/pull-requests.md`).

## On-demand rules

Load these when the task touches them (not always-loaded):

- `@.claude/rules/tech-stack.md` — the five tools + companion CLIs + the keyboard-layer contract.
- `@.claude/rules/config.md` — cross-tool config conventions (never-invent, one-file-owns-one-concern).
- `@.claude/rules/testing.md` — validation: how each tool's config is proven to load.
- `@.claude/rules/tooling.md` — Homebrew install + the validators/formatters.
- `@.claude/rules/naming.md` — folder/file layout per tool.
- `@.claude/rules/commits.md` · `@.claude/rules/pull-requests.md` — commit + PR format.
- `@.claude/rules/comments.md` · `@.claude/rules/claude-md.md` — what earns a comment / a doc line.
- `@.claude/rules/sdd.md` — the SDD toolkit build contract (fork map, no-config agent model).

## Maintaining these docs

A `CLAUDE.md`/rule caches what the **config cannot say** — the *why*, not the *what*. If a rebind
forces a doc edit, the doc was holding *what*; move it back to the config. Refresh only when a real
change lands, then run `/check`. (`@.claude/rules/claude-md.md`)
