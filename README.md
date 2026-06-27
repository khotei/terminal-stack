<div align="center">

# 🖥️ terminal-stack

**A modern, terminal-first dev environment — built to live in.**

Ghostty · Zellij · Neovim + LazyVim · zsh + Starship · Claude Code

<br/>

[![Stack](https://img.shields.io/badge/stack-Ghostty%20%2B%20Zellij%20%2B%20LazyVim-blue)](#-the-stack)
[![Platform](https://img.shields.io/badge/platform-macOS%20%C2%B7%20Linux-lightgrey)](#-requirements)
[![Built with SDD](https://img.shields.io/badge/built%20with-Spec--Driven%20Development-8A2BE2)](#-how-this-repo-is-built)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

<sub>Keyboard-driven · GPU-fast · low-RAM · agent-native — a calm place to write code next to an AI.</sub>

</div>

---

## ✦ What is this

`terminal-stack` is a curated, **reference-grade** configuration for a terminal-first workflow on
macOS (and Linux). It is the answer to a simple question:

> *If you migrate off a heavy IDE (JetBrains / VS Code / Cursor) and want to live in the terminal
> next to Claude Code — what's the cleanest, fastest, most ergonomic setup in 2026?*

Every config here is **documented like a manual, not dumped like a dotfile**: *what* changed, *why*
each setting exists, *how* to try it, and the keybindings it gives you. You can read this repo
top-to-bottom and come out knowing the stack — not just copying it.

> 🧭 **New to the stack? Start with the [Developer's Guide](docs/guide.md)** — the mental model, cheat
> sheets, and scenario-by-scenario walkthroughs of how a developer actually works in it.
>
> ⌨️ **Coming from JetBrains/IntelliJ?** The [JetBrains → stack review map](docs/jetbrains-to-stack-review.md)
> translates the IDE hotkeys you know (definition, usages, docs, structure, diff review) into this stack.

## ✦ The stack

| Layer | Tool | Why it's here |
|------|------|---------------|
| **Terminal** | [**Ghostty**](https://ghostty.org) | GPU-accelerated, native, single-file config. The fastest, lowest-friction emulator on macOS right now. |
| **Multiplexer** | [**Zellij**](https://zellij.dev) | Modern tmux alternative — sane defaults, discoverable UI, KDL config, sessions-as-workspaces. |
| **Editor** | [**Neovim**](https://neovim.io) + [**LazyVim**](https://lazyvim.org) | The "IDE in the terminal." LazyVim brings LSP, the snacks picker, which-key, Treesitter, git — the JetBrains muscle memory survives. |
| **Shell** | **zsh** + [**Starship**](https://starship.rs) | Fast prompt, plus power-ups: autosuggestions · syntax-highlighting · fzf-tab, and `eza`/`bat`/`delta` · `zoxide` · `atuin` · `fzf` · `fd` · `ripgrep` · `lazygit` · `yazi`. |
| **Agent** | [**Claude Code**](https://docs.claude.com/en/docs/claude-code) | Lives in a multiplexer pane beside Neovim. Less RAM, tighter feedback loop, better agentic flow than embedded IDE versions. |

> **The pattern:** one Zellij session per project → split into **Neovim** (edit) ∣ **Claude Code**
> (agent), with vim-style pane navigation (`Ctrl-hjkl`) tying it together. Worktrees for parallel
> agents.

## ✦ Requirements

- **macOS** (primary) or **Linux**.
- That's it — `bootstrap.sh` installs the Xcode Command Line Tools + [Homebrew](https://brew.sh) for
  you. (On Linux, install Homebrew first, then run `brew bundle && ./install.sh`.) A fresh install is
  a multi-minute Homebrew download.
- **A Nerd Font** for the icons in the prompt, status line, and editor — **handled for you**: the repo
  bundles Dank Mono and the Brewfile installs Nerd Fonts.
- The **Agent layer needs an Anthropic account** — Claude Code installs via `brew bundle`; run
  `claude` once and log in.

## ✦ Quickstart

### What actually runs

`bootstrap.sh` is the **one command** for a fresh Mac. It runs four stages in order — idempotent, so
re-running just skips anything already there:

```text
  ./bootstrap.sh  ──  one command, four stages
      │
      ①  Xcode CLT     git · compiler · make             (prep · skipped if present)
      ②  Homebrew      the package manager               (prep · skipped if present)
      ③  brew bundle   the toolchain:  Ghostty · Zellij · Neovim · Starship · CLIs · fonts
      ④  install.sh    symlink configs → ~/.config · copy fonts · fetch autolock plugin
      │
      ▼
   stack installed
```

```bash
git clone https://github.com/khotei/terminal-stack.git ~/terminal-stack
cd ~/terminal-stack && ./bootstrap.sh
```

**Already have Homebrew?** Stages ③–④ are all `bootstrap` does after the prep — run them yourself:

```bash
brew bundle     # ③ the toolchain   · trim the Brewfile's Personal section first if you want
./install.sh    # ④ symlink configs · --dry-run previews; anything replaced is backed up to .bak
# Linux: install Homebrew yourself first (bootstrap.sh is macOS-only), then the two lines above.
```

### Then — what to run after

The stack is installed. These finish and personalise it; only the first two are needed to *use* it:

| | Run | What it does |
|---|---|---|
| **required** | open a new terminal | loads zsh + Starship — your shell is ready |
| **required** | `zellij --layout dev` | the **Neovim │ Claude Code** split — the actual workflow |
| for Claude's status line | add the `statusLine` block to `~/.claude/settings.json` | the model · dir · git · cost line ([how](docs/install.md#status-line)) |
| recommended | `make git-setup` | set your git name/email in `~/.gitconfig` (never committed) |
| optional | `make macos` | opinionated macOS defaults — Dock, Vim key-repeat, trackpad (**opt-in**; `--dry-run` previews) |
| optional | `make jetbrains` | link `~/.ideavimrc` + import IDE settings, if you still use a JetBrains IDE (**opt-in**; `--dry-run`) |
| optional | `make cursor` | link Cursor settings/keybindings + vscode-neovim `init.lua`, if you use Cursor (**opt-in**; `--dry-run`) |
| anytime | `make doctor` | read-only health check — is every tool + symlink in place? |
| anytime | `make update` | pull configs + upgrade tools + prune stale links |

`make help` lists every target. Full walkthrough with the per-setting detail:
[`docs/install.md`](docs/install.md).

> **Safe by default:** `install.sh` backs up anything it replaces to `*.bak` and previews with
> `--dry-run`; `make macos` / `make git-setup` never run unless you call them. The first `nvim` launch
> installs the LazyVim plugins. To revert: remove the symlinks and restore the `.bak` files
> ([uninstall](docs/install.md#uninstall)).

Each config directory carries its **own README** with the per-setting reference — so you can read or
adopt one layer at a time.

### Try it without touching your machine

No install required to *test* the in-terminal layers — there's a disposable Docker sandbox:

```bash
make try      # build + drop into a fully-configured zsh (Zellij + Neovim + Starship)
make zellij   # jump straight into the multiplexer
make check    # run the config validators (also runs in CI on every PR)
```

The repo is mounted live, so edits show up instantly. Ghostty isn't in the sandbox — it's a host
GUI app — see [`docs/sandbox.md`](docs/sandbox.md).

## ✦ Repo layout

```
terminal-stack/
├── ghostty/        # Ghostty config — key = value          — see ghostty/README.md
├── zellij/         # Zellij KDL config, layouts, autolock   — see zellij/README.md
├── nvim/           # Neovim + LazyVim starter (Lua)         — see nvim/README.md
├── zsh/            # .zshrc, Starship, shell integrations    — see zsh/README.md
├── claude/         # Claude Code status line + cc-worktree   — see claude/README.md
├── fonts/          # bundled Dank Mono (.otf)                — see fonts/README.md
├── git/            # delta diffs, defaults + identity setup   — see git/README.md
├── macos/          # opt-in macOS system defaults script     — see macos/README.md
├── jetbrains/      # opt-in IdeaVim + IDE settings (link by demand) — see jetbrains/README.md
├── cursor/         # opt-in Cursor settings + vscode-neovim init (link by demand) — see cursor/README.md
├── docs/           # guide.md · install.md · sandbox.md      — see docs/README.md
├── scripts/        # check.sh + entrypoint.sh (sandbox/CI)
├── .claude/        # the SDD toolkit that builds this repo (see below)
├── bootstrap.sh    # fresh-Mac one-shot: CLT + Homebrew → brew bundle → install.sh
├── install.sh      # symlink every config into ~/.config etc. (idempotent)
├── Brewfile        # the toolchain (brew bundle)
├── Makefile        # try/zellij/check/install/update — `make help` lists all
├── CLAUDE.md       # always-loaded guidance for Claude Code
└── README.md       # you are here
```

## ✦ How Claude Code fits

Claude Code is a TUI, so it lives **in a multiplexer pane** — not an IDE sidebar. The endorsed layout:

```
┌──────────────────────────────┬───────────────────────────┐
│                              │                           │
│   Neovim (edit + navigate)   │   Claude Code (the agent) │
│                              │                           │
├──────────────────────────────┴───────────────────────────┤
│   Zellij status bar · session: my-project · tab: feat/x  │
└───────────────────────────────────────────────────────────┘
```

- **The panes start as shells** — type `nvim` (left) and `claude` (right) to fill them, or uncomment
  the `dev` layout's `command` lines to auto-launch them.
- **Switch editor ↔ agent** with vim-style pane nav (`Ctrl-hjkl`).
- **`zellij-autolock`** (on by default) keeps Zellij keys from colliding with Neovim / Claude Code.
- **One session per project / task**; git **worktrees** for parallel agents.

## ✦ How this repo is built

This repo is assembled with **Spec-Driven Development (SDD)** — every config surface is specified,
planned, and verified before it ships, and tracked live in Notion. The loop:

```
research? → specify → clarify → plan → tasks → implement → verify
```

The `/sdd:*` Claude Code commands in [`.claude/`](.claude/) run that loop. Concretely:

1. **`/sdd:specify`** — draft a Feature (e.g. *Ghostty config*) with EARS acceptance criteria.
2. **`/sdd:clarify`** — resolve every open `[TBD]`, one question at a time.
3. **`/sdd:plan`** → **`/sdd:tasks`** — decompose into vertical, reviewable slices.
4. **`/sdd:implement`** — build one task, validate it (`/check`), ship a PR **formatted as a
   reference guide**.
5. **`/sdd:verify`** — a fresh-context agent checks the ACs before `Done`.

That's why every PR here is a guide: it's a requirement of the process, not an afterthought. See
[`.claude/commands/README.md`](.claude/commands/README.md) for the full toolkit.

## ✦ Roadmap

Each item is one SDD Feature → one (or a few) reference-guide PR(s).

- [x] **Meta** — repo scaffold, README, `.claude/` toolkit · Docker sandbox + CI · `Brewfile` + `install.sh`
- [x] **Terminal** — Ghostty config (font, Catppuccin Mocha, `macos-option-as-alt`, `ctrl+a` left free)
- [x] **Multiplexer** — Zellij config + `dev` layout + `ctrl+a` prefix, autolock opt-in
- [x] **Editor** — Neovim + LazyVim starter, Catppuccin, pinned `lazy-lock.json`
- [x] **Shell** — zsh + Starship (Catppuccin) + zoxide/atuin/fzf
- [x] **Agent** — Claude Code statusline + worktree helper + pane workflow

> **v1 complete.** Next (v1.1): `zellij-autolock` wired by default, deeper LSP/DAP, an IdeaVim
> keymap port, atuin sync, screenshots.

## ✦ Credits & references

- [Ghostty docs](https://ghostty.org/docs) · [Zellij docs](https://zellij.dev/documentation) ·
  [LazyVim docs](https://lazyvim.org) · [Starship](https://starship.rs) ·
  [Claude Code](https://docs.claude.com/en/docs/claude-code)
- Stack inspiration from the 2026 "terminal-first + Claude Code" community on X.

<div align="center">
<br/>
<sub>Built keyboard-first, in the terminal, with Claude Code. · MIT</sub>
</div>
