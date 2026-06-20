---
description: Validate the stack's config files (Ghostty, Zellij, Neovim, zsh) and report failures
---

**Canonical form:** the validators are codified in [`scripts/check.sh`](../../scripts/check.sh) —
the same script `make check` and CI run, so there is no drift. Prefer running it directly
(`bash scripts/check.sh`, or `make check` for the Linux-accurate sandbox run); the steps below
document what it does and how to interpret a failure. The Docker sandbox is in
[`docs/sandbox.md`](../../docs/sandbox.md).

Run the available config validators and report results concisely. This stack has **no compiler** —
"check" means *does each config actually load?* Run every validator whose tool is installed; **skip
and note** any whose tool is missing (degrade gracefully — never fail the whole run because a tool
isn't on this machine).

For each step, first confirm the tool exists (e.g. `command -v ghostty`); if absent, report
`SKIP — <tool> not installed` and move on.

1. **Ghostty** — `ghostty +show-config` (parses `ghostty/config`; any unknown key or syntax error
   surfaces here). Report PASS/FAIL + the offending key on failure.
2. **Zellij** — `zellij setup --check` (verifies the config/layout files load).
3. **Neovim health** — `nvim --headless "+checkhealth" +qa` for a full health report; and/or, to
   prove a specific Lua file loads, `nvim --headless -c 'luafile <file>' -c qa` (non-zero exit / Lua
   error = FAIL). Run health for broad checks, `luafile` when you touched one module.
4. **zsh** — `zsh -n <file>` syntax-checks a shell file without executing it. Run it over each
   touched `zsh/*.zsh` / `.zshrc` (so a typo can't break login shells).
5. **Formatters (if present)** — `stylua --check nvim/` for Lua and `shfmt -d zsh/` for shell. These
   are style gates, not load checks; report them separately and treat a diff as a soft FAIL (run
   `stylua` / `shfmt -w` to fix).

For each step report **PASS / FAIL / SKIP**. On FAIL, show the specific error (file:line + message)
and stop — do not attempt fixes unless asked. If everything passes (or is cleanly skipped), say so
in one line.

> Install the validators via Homebrew: `brew install ghostty zellij neovim stylua shfmt`
> (`zsh` ships with macOS). See `@.claude/rules/tooling.md`.
