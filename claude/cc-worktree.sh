#!/usr/bin/env bash
# cc-worktree.sh <branch> [base] — spin up a git worktree for a PARALLEL Claude Code
# agent and open a Zellij session (dev layout) in it. Worktrees let several agents
# work the same repo on different branches at once without colliding.
# Install: symlink onto $PATH (e.g. ~/.local/bin/cc-worktree). See ./README.md.
set -euo pipefail

branch=${1:?usage: cc-worktree <branch> [base-ref]}
base=${2:-HEAD}

repo=$(git rev-parse --show-toplevel)
name=$(basename "$repo")
slug=${branch//\//-}
dir="${repo}/../${name}-${slug}"
session="${name}-${slug}"

git worktree add -b "$branch" "$dir" "$base"
echo "✓ worktree: $dir  ·  branch: $branch"

if command -v zellij >/dev/null 2>&1; then
  cd "$dir"
  exec zellij --session "$session" --layout dev
else
  echo "→ cd \"$dir\" and start your editor │ agent split"
fi
