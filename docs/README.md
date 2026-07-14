# 📚 docs

The written half of terminal-stack — the reference guides that turn the configs into a workflow you
can actually live in. Five docs, by intent:

| Doc | Read it to… |
|---|---|
| **[guide.md](guide.md)** | **Learn the stack** — the mental model, how the tools are wired into one workflow, and scenario-by-scenario walkthroughs. Per-tool keys live in each layer's README. |
| **[install.md](install.md)** | **Set it up** — `bootstrap.sh` → `brew bundle` → `install.sh`, updating, troubleshooting, uninstall. |
| **[sandbox.md](sandbox.md)** | **Try it first** — `make try` runs the in-terminal layers in a disposable Docker container, no install. |
| **[jetbrains-to-stack-review.md](jetbrains-to-stack-review.md)** | **Migrate from JetBrains** — the IDE-hotkey → stack map for reading, navigating, and reviewing code. |
| **[parallel-agents.md](parallel-agents.md)** | **Run several agents at once** — why one shared tree collides, the two isolation modes, worktrees per agent, and merging the parallel branches back. |
| **[composing-tools.md](composing-tools.md)** | **Pipe the CLIs together** — how `fd`/`rg`/`fzf` compose, and how a result crosses into Neovim, Claude Code, or lazygit and back. The joins, not the per-tool cards. |
| **[reviewing-changes.md](reviewing-changes.md)** | **Review what the agent wrote** — reading AI changes (committed *and* uncommitted) efficiently: diffview with live LSP, `git add -p` as a gate, reviewing *with* Claude, and what to hunt for in AI code. |

**Per-layer references** (one README per tool, with the per-setting rationale):
[ghostty](../ghostty/README.md) · [zellij](../zellij/README.md) · [nvim](../nvim/README.md) ·
[zsh](../zsh/README.md) · [git](../git/README.md) · [claude](../claude/README.md) ·
[fonts](../fonts/README.md) · [macos](../macos/README.md).

> **System:** macOS defaults via `make macos` (opt-in — not run by bootstrap/install); see
> [macos](../macos/README.md).

> New here? Start with [guide.md → First five minutes](guide.md#first-five-minutes).
