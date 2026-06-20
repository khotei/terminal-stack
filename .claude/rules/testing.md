---
paths:
  - "ghostty/**"
  - "zellij/**"
  - "nvim/**"
  - "zsh/**"
---

# Validation (the "testing" of a config repo)

There is no application code here, so there are no unit tests. "Testing" means one thing: **does each
config actually load?** A config that parses cleanly *and* produces the intended keypress/behavior is
the equivalent of a green test. The single entry point is `/check`
(`@.claude/commands/check.md`) — it runs every validator below and degrades gracefully when a tool
isn't installed.

## What "loads" means per tool

| Tool | Validator | Green = |
|---|---|---|
| **Ghostty** | `ghostty +show-config` | parses `ghostty/config`; no unknown key / syntax error |
| **Zellij** | `zellij setup --check` | config + layouts load without error |
| **Neovim** | `nvim --headless "+checkhealth" +qa` | health report has no errors; *or* `nvim --headless -c 'luafile <file>' -c qa` exits 0 (the Lua module loads) |
| **zsh** | `zsh -n <file>` | shell file is syntactically valid (does **not** execute it) |
| **Lua style** | `stylua --check nvim/` | formatting matches (style gate, not a load check) |
| **shell style** | `shfmt -d zsh/` | formatting matches (style gate) |

Run the **load** validators on every change; the **style** validators are a soft gate (`stylua` /
`shfmt -w` to fix). `zsh -n` is the cheapest guard there is — run it over any touched shell file so a
typo can't break login shells.

## Two things a validator can't prove

1. **The keypress actually does the thing.** `ghostty +show-config` proves the bind *parses*, not
   that pressing it spawns a tab. For a behavior only a keypress can show, the verifier reproduces it
   and observes the result (`@.claude/agents/verifier.md`).
2. **No collision across layers.** A bind can be valid in isolation yet shadow the multiplexer prefix
   or the editor leader. Collisions are caught by reading the keymap, not by a validator — see the
   invariant in `@.claude/rules/config.md`.

## When to run it

- During `/sdd:implement`: before marking any task `Done`.
- During `/sdd:verify`: as the evidence behind each AC's pass/fail (cite the exact command + output).
- Locally any time, on demand. There is no commit hook that runs it for you — `/check` is manual.
