#!/usr/bin/env bash
# Install the user-scope Claude Code plugins the agent layer enables. Idempotent: a
# plugin already installed is left as-is. No secrets, no auth — all four ship from the
# preloaded `claude-plugins-official` marketplace. `enabledPlugins` in settings.json only
# ENABLES a plugin; on a fresh machine it does NOT fetch it — an enabled-but-absent plugin
# is silently skipped (anthropics/claude-code#32607), so the install has to live here.
set -euo pipefail

# Best-effort: without the CLI there is nothing to install — let install.sh continue.
command -v claude >/dev/null 2>&1 || { echo "claude CLI not found — run 'brew bundle', then re-run." >&2; exit 0; }

MARKET=claude-plugins-official

add() { # add <plugin>
  local name="$1"
  if claude plugin list 2>/dev/null | grep -q "${name}@${MARKET}"; then
    printf '  ok: %s already installed\n' "$name"
  else
    claude plugin install "${name}@${MARKET}" --scope user
  fi
}

add typescript-lsp
add commit-commands
add pr-review-toolkit
add frontend-design

cat <<'DONE'

Plugins installed (user scope) — enabled via settings.json#enabledPlugins.
DONE
