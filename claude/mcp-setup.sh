#!/usr/bin/env bash
# Register the user-scope MCP servers the agent layer relies on. Idempotent: a
# server already present is left as-is. No secrets live here — Notion authenticates
# over OAuth (run `/mcp` once; the token lands in the OS keychain). A server a project
# needs, such as Context7, lives in that project's .mcp.json. A future token-based server reads ${VAR} from ~/.zshrc.local, never a
# committed file (see ../.claude/rules/config.md §Secrets · README "Settings, plugins & MCP").
set -euo pipefail

# Best-effort: without the CLI there is nothing to register — let install.sh continue.
command -v claude >/dev/null 2>&1 || { echo "claude CLI not found — run 'brew bundle', then re-run." >&2; exit 0; }

add() { # add <name> <url>
  local name="$1" url="$2"
  if claude mcp get "$name" >/dev/null 2>&1; then
    printf '  ok: %s already registered\n' "$name"
  else
    claude mcp add --transport http -s user "$name" "$url"
  fi
}

add notion https://mcp.notion.com/mcp

cat <<'DONE'

MCP server registered (user scope). Finish Notion auth once:
  open `claude` → /mcp → notion → Authenticate (browser sign-in; token goes to the OS keychain).
DONE
