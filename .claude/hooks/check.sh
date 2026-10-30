#!/bin/sh
# Stop gate for the implementer agent: it finishes only with a green scripts/check.sh.
# A final message that starts with "BLOCKED:" passes, so a stuck agent can still report why.
# Only exit 2 blocks a stop; any other non-zero code would let it through.

input=$(cat)
message=$(printf '%s' "$input" | jq -r '.last_assistant_message // ""')
case "$(printf '%s' "$message" | sed -e 's/^[[:space:]]*//' | head -c 8)" in
  BLOCKED:) exit 0 ;;
esac

# The agent's own tree: an agent started with `isolation: worktree` works outside CLAUDE_PROJECT_DIR.
cwd=$(printf '%s' "$input" | jq -r '.cwd // ""')
dir=$(git -C "${cwd:-${CLAUDE_PROJECT_DIR:-.}}" rev-parse --show-toplevel 2>/dev/null)
if [ -z "$dir" ] || ! cd "$dir" 2>/dev/null; then
  {
    echo "check.sh cannot find the agent's git tree (cwd: $cwd), so scripts/check.sh did not run."
    echo "Fix it before finishing, or start your final message with BLOCKED: and explain why."
  } >&2
  exit 2
fi
if output=$(bash scripts/check.sh 2>&1); then
  exit 0
fi

{
  echo "scripts/check.sh is red. Fix it before finishing, or start your final message with BLOCKED:"
  echo "and explain why the step cannot be finished. Last 60 lines:"
  echo
  printf '%s\n' "$output" | tail -n 60
} >&2
exit 2
