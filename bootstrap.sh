#!/usr/bin/env bash
# terminal-stack bootstrap — take a fresh Mac from zero to a working stack.
# Ensures the Xcode Command Line Tools + Homebrew, installs the toolchain
# (brew bundle), then symlinks the configs (install.sh). Idempotent — safe to
# re-run; anything already present is skipped.
#
# Usage:  ./bootstrap.sh [install.sh flags…]   (e.g. --dry-run)
# Reference: docs/install.md
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
step() { printf '\n\033[1m→ %s\033[0m\n' "$*"; }

if [ "$(uname -s)" != "Darwin" ]; then
  echo "bootstrap.sh targets macOS. On Linux: install Homebrew (brew.sh), then run" >&2
  echo "  brew bundle && ./install.sh" >&2
  exit 1
fi

# 1. Xcode Command Line Tools — git/cc/make. The Homebrew installer (step 2)
#    installs these itself if missing; we just surface the state.
step "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  echo "  ok: already installed"
else
  echo "  not found — the Homebrew installer will add them (a dialog may appear; accept it)."
fi

# 2. Homebrew — install if missing, then put it on PATH for this session
#    (Apple Silicon → /opt/homebrew, Intel → /usr/local).
step "Homebrew"
if command -v brew >/dev/null 2>&1; then
  echo "  ok: $(brew --version | head -1)"
else
  echo "  installing Homebrew (non-interactive)…"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if   [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew  ]; then eval "$(/usr/local/bin/brew shellenv)"
fi
command -v brew >/dev/null 2>&1 || { echo "brew still not on PATH — open a new shell and re-run" >&2; exit 1; }

# 3. The toolchain.
step "brew update + bundle"
brew update
brew bundle --file="$REPO/Brewfile"

# 4. The configs (+ fonts). Forward any flags (e.g. --dry-run).
step "Linking configs"
"$REPO/install.sh" "$@"

printf '\n\033[32m✓ bootstrap complete.\033[0m Open a new terminal, then:  zellij --layout dev\n'
printf '  (later, to update everything:  make update)\n'
