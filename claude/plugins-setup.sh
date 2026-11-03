#!/usr/bin/env bash
# Install the one user-scope Claude Code plugin, WakaTime. Idempotent: a plugin already
# installed is left as-is. Every other plugin belongs to the project that needs it: its
# .claude/settings.json enables it, and its own setup installs one from an outside source.
# `enabledPlugins` in settings.json only ENABLES a plugin; on a fresh machine it does NOT
# fetch it (anthropics/claude-code#32607), so the install has to live here.
set -euo pipefail

# Best-effort: without the CLI there is nothing to install — let install.sh continue.
command -v claude >/dev/null 2>&1 || { echo "claude CLI not found — run 'brew bundle', then re-run." >&2; exit 0; }

# WakaTime ships from its own marketplace (registered in settings.json#extraKnownMarketplaces),
# not claude-plugins-official — install by fully-qualified name. Reads the api_key from
# ~/.wakatime.cfg (never committed). Pairs with nvim/lua/plugins/wakatime.lua on one dashboard.
if claude plugin list 2>/dev/null | grep -q "claude-code-wakatime@wakatime"; then
  printf '  ok: %s already installed\n' claude-code-wakatime
else
  claude plugin install claude-code-wakatime@wakatime --scope user
fi

cat <<'DONE'

Plugin installed (user scope) — enabled via settings.json#enabledPlugins.
DONE
