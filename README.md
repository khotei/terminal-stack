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
macOS (and, increasingly, Linux). It is the answer to a simple question:

> *If you migrate off a heavy IDE (JetBrains / VS Code / Cursor) and want to live in the terminal
> next to Claude Code — what's the cleanest, fastest, most ergonomic setup in 2026?*

Every config here is **documented like a manual, not dumped like a dotfile**. Each pull request reads
as a self-contained reference guide: *what* changed, *why* each setting exists, *how* to try it, and
the keybindings it gives you. You can read this repo top-to-bottom and come out knowing the stack —
not just copying it.

<div align="center">
<sub>📸 <i>screenshot goes here once the first configs land — see</i> <code>docs/assets/</code></sub>
</div>

## ✦ The stack

| Layer | Tool | Why it's here |
|------|------|---------------|
| **Terminal** | [**Ghostty**](https://ghostty.org) | GPU-accelerated, native, single-file config. The fastest, lowest-friction emulator on macOS right now. |
| **Multiplexer** | [**Zellij**](https://zellij.dev) | Modern tmux alternative — sane defaults, discoverable UI, KDL config, sessions-as-workspaces. |
| **Editor** | [**Neovim**](https://neovim.io) + [**LazyVim**](https://lazyvim.org) | The "IDE in the terminal." LazyVim brings LSP, Telescope, which-key, Treesitter, git — the JetBrains muscle memory survives. |
| **Shell** | **zsh** + [**Starship**](https://starship.rs) | Fast prompt, sensible completions, plus `zoxide` · `atuin` · `fzf` · `fd` · `ripgrep` · `lazygit` · `yazi`. |
| **Agent** | [**Claude Code**](https://docs.claude.com/en/docs/claude-code) | Lives in a multiplexer pane beside Neovim. Less RAM, tighter feedback loop, better agentic flow than embedded IDE versions. |

> **The pattern:** one Zellij session per project → split into **Neovim** (edit) ∣ **Claude Code**
> (agent), with vim-style pane navigation (`Ctrl-hjkl`) tying it together. Worktrees for parallel
> agents.

## ✦ Requirements

- **macOS** (primary) or **Linux**
- [**Homebrew**](https://brew.sh) — everything installs through it
- A [**Nerd Font**](https://www.nerdfonts.com/) for icons (the configs assume one)

## ✦ Quickstart

```bash
# 1. clone
git clone https://github.com/khotei/terminal-stack.git ~/terminal-stack
cd ~/terminal-stack

# 2. install the toolchain (Ghostty, Zellij, Neovim, Starship, companions, fonts)
brew bundle

# 3. symlink every config into place — idempotent, backs up anything in the way
#    (preview first with: ./install.sh --dry-run)
./install.sh
```

Then add the status-line block to `~/.claude/settings.json`, open a new terminal, and run
`zellij --layout dev`. **Update later** with `make update` (pull + upgrade tools + prune stale links).
Full walkthrough: [`docs/install.md`](docs/install.md).

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
├── ghostty/        # Ghostty config — key = value, ~/.config/ghostty/config
├── zellij/         # Zellij KDL config, layouts, plugin setup (zellij-autolock)
├── nvim/           # Neovim + LazyVim starter, plugin specs, keymaps (Lua)
├── zsh/            # .zshrc, Starship, shell integrations
├── docs/           # guides, cheatsheets, screenshots
├── .claude/        # the SDD toolkit that builds this repo (see below)
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

- **Switch editor ↔ agent** with vim-style pane nav (`Ctrl-hjkl`).
- **`zellij-autolock`** keeps Zellij keys from colliding with Neovim / Claude Code.
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
