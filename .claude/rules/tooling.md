---
paths:
  - "scripts/**"
  - "*.sh"
  - "Makefile"
  - "Brewfile"
  - "Dockerfile"
  - ".github/workflows/**"
---

# Tooling

The stack installs and validates through a small, standard set of CLIs, all from **Homebrew**.

## Install

The `Brewfile` is the one list of what the stack needs: `brew bundle` installs it, `make bootstrap`
takes a fresh Mac there. `zsh` ships with macOS. A tool the configs start to rely on goes into the
`Brewfile` in the same commit.

## Validators

`scripts/check.sh` is the one list of validators and what each proves; `make check-local`, `make
check` (the Linux sandbox), CI and `/check` all run it. It **skips and notes** a validator whose
tool isn't installed rather than failing the whole run. A new validator goes into the script, not
into a doc.

## Formatters

- **`stylua`** formats Neovim Lua. Config lives in `stylua.toml` (or `.stylua.toml`) at the repo
  root if present; otherwise it uses defaults. `stylua --check` is the gate, `stylua` (write) the fix.
- **`shfmt`** formats zsh / shell. `shfmt -d` diffs, `shfmt -w` writes.

These are **style** gates, not load checks — a formatting diff is a soft fail. The load validators
are the hard gate.

## No commit hook

No hook runs the validators on `git commit`: CI runs `scripts/check.sh` on every PR and every push
to `main`, and locally it is run by hand (and by the SDD loop before a task is `Done`).
