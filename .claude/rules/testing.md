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
the equivalent of a green test. The validators and what each proves live in one place,
`scripts/check.sh` (`@.claude/rules/tooling.md`); it skips a tool that isn't installed.

## What a validator can't prove

1. **The keypress actually does the thing.** `ghostty +show-config` proves the bind *parses*, not
   that pressing it spawns a tab. For a behavior only a keypress can show, the verifier reproduces it
   and observes the result (`@.claude/agents/verifier.md`).
2. **No collision across layers.** A bind can be valid in isolation yet shadow a Zellij mode key
   or the editor leader. Collisions are caught by reading the keymap, not by a validator — see the
   invariant in `@.claude/rules/config.md`.
3. **A misspelt option name, in some tools.** `zellij setup --check` answers *Well defined* for an
   unknown option (`rounded_cornrs`) while it does catch a syntax error or an unknown action; a
   typo'd field in a plugin's Lua `opts` table is usually ignored the same way. Confirm the name against the
   installed version first (`@.claude/rules/config.md`).

## When to run it

- During `/sdd:implement`: before marking any task `Done`.
- During `/sdd:verify`: as the evidence behind each AC's pass/fail (cite the exact command + output).
- On every PR and push to `main`, in CI; locally on demand (`/check`, `make check-local`).
