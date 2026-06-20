#!/usr/bin/env bash
# scripts/check.sh — the stack's single validation entrypoint.
# Shared verbatim by `make check`, GitHub Actions CI, and the /check command
# (@.claude/commands/check.md) so there is no drift between local and CI.
#
# Contract (F-META-001, AC-4): run each tool's validator IFF both the config and
# the tool are present; otherwise print a SKIP note. Exit non-zero only on a real
# validation FAILURE. Style gates (stylua/shfmt) are soft — they warn, never fail.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

fail=0
pass()  { printf '  \033[32m✓\033[0m %s\n' "$1"; }
fault() { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=1; }
skip()  { printf '  \033[33m↷\033[0m %s \033[2m(skip)\033[0m\n' "$1"; }
warn()  { printf '  \033[33m!\033[0m %s\n' "$1"; }
head()  { printf '\n\033[1m%s\033[0m\n' "$1"; }
have()  { command -v "$1" >/dev/null 2>&1; }

# ── Ghostty (host-only; usually skipped in CI/container) ──────────────
head "Ghostty"
if [ -f ghostty/config ]; then
  if have ghostty; then
    if ghostty +show-config >/dev/null 2>&1; then pass "ghostty +show-config"; else fault "ghostty +show-config rejected the config"; fi
  else skip "ghostty not installed — host-only GUI app, validate on a real machine"; fi
else skip "no ghostty/config"; fi

# ── Zellij ────────────────────────────────────────────────────────────
head "Zellij"
if [ -f zellij/config.kdl ]; then
  if have zellij; then
    if zellij --config zellij/config.kdl setup --check >/dev/null 2>&1; then pass "zellij setup --check"; else fault "zellij setup --check failed"; fi
  else skip "zellij not installed"; fi
else skip "no zellij/config.kdl"; fi

# ── Neovim (light load; LazyVim may bootstrap plugins — see docs/sandbox.md) ──
head "Neovim"
if [ -f nvim/init.lua ]; then
  if have nvim; then
    if timeout 120 nvim --headless -u nvim/init.lua +qa >/dev/null 2>&1; then pass "nvim loads init.lua"; else fault "nvim failed to load init.lua"; fi
  else skip "nvim not installed"; fi
else skip "no nvim/init.lua"; fi

# ── Shell (zsh syntax check, no execution) ────────────────────────────
head "Shell (zsh -n)"
shell_files=$(ls zsh/.zshrc zsh/*.zsh 2>/dev/null || true)
if [ -n "$shell_files" ]; then
  if have zsh; then
    for f in $shell_files; do
      if zsh -n "$f" 2>/dev/null; then pass "zsh -n $f"; else fault "zsh -n $f — syntax error"; fi
    done
  else skip "zsh not installed"; fi
else skip "no zsh files yet"; fi

# ── Style gates (soft — warn, never fail the run) ─────────────────────
head "Style (soft)"
if [ -d nvim ] && ls nvim/**/*.lua nvim/*.lua >/dev/null 2>&1; then
  if have stylua; then stylua --check nvim/ >/dev/null 2>&1 && pass "stylua --check nvim/" || warn "stylua: formatting diff (run: stylua nvim/)"; else skip "stylua not installed"; fi
else skip "no Lua files"; fi
if [ -n "${shell_files:-}" ]; then
  if have shfmt; then shfmt -d zsh/ >/dev/null 2>&1 && pass "shfmt -d zsh/" || warn "shfmt: formatting diff (zsh syntax may not be fully supported)"; else skip "shfmt not installed"; fi
else skip "no shell files"; fi

# ── Verdict ───────────────────────────────────────────────────────────
if [ "$fail" -eq 0 ]; then printf '\n\033[32m✓ check: all present configs valid\033[0m\n'; else printf '\n\033[31m✗ check: a validator failed\033[0m\n'; fi
exit "$fail"
