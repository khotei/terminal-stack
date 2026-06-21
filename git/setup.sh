#!/usr/bin/env bash
# git/setup.sh — set your git IDENTITY (name, email, optional signing key) for a
# fresh environment, or change it later. Writes ONLY to ~/.gitconfig — your
# machine-local identity that is never committed — and never touches the repo's
# shared ~/.config/git/config (delta + defaults), which carries no [user] block.
#
# Why a script, not a committed file: this is a PUBLIC repo, so your name/email
# must never live in git. install.sh links the shared defaults; this sets the
# personal identity those defaults deliberately leave out.
#
# Usage:  ./git/setup.sh [--name "Your Name"] [--email you@example.com]
#                        [--signing-key KEY] [--show] [--dry-run]   (or: make git-setup)
#   (no flags)      interactive — shows each current value, Enter keeps it
#   --name/--email  set non-interactively (a fresh box, or scripting)
#   --signing-key   also set user.signingkey + commit.gpgsign=true (sign commits)
#   --show          print the current identity and exit (read-only)
#   --dry-run       print the git commands it would run, change nothing
# Reference: git/README.md · https://git-scm.com/docs/git-config
set -euo pipefail

command -v git >/dev/null 2>&1 || { echo "git/setup.sh: git not found (install the Xcode CLT / brew bundle)" >&2; exit 1; }

# Pin the target file. `git config --global` would write into the symlinked
# ~/.config/git/config when ~/.gitconfig is absent — leaking identity into the
# public repo. --file keeps every write in the machine-local identity file.
GITCONFIG="${HOME}/.gitconfig"
DRY_RUN=false; SHOW=false
opt_name=""; opt_email=""; opt_key=""

while [ $# -gt 0 ]; do
  case "$1" in
    --name)        opt_name="${2:?--name needs a value}"; shift 2 ;;
    --email)       opt_email="${2:?--email needs a value}"; shift 2 ;;
    --signing-key) opt_key="${2:?--signing-key needs a value}"; shift 2 ;;
    --show)        SHOW=true; shift ;;
    --dry-run)     DRY_RUN=true; shift ;;
    -h|--help)
      cat <<'USAGE'
git/setup.sh — set your git identity in ~/.gitconfig (never committed).

Usage:  ./git/setup.sh [--name "Your Name"] [--email you@example.com]
                       [--signing-key KEY] [--show] [--dry-run]
  (no flags)      interactive — shows each current value, Enter keeps it
  --name/--email  set non-interactively
  --signing-key   also set user.signingkey + commit.gpgsign=true
  --show          print the current identity and exit (read-only)
  --dry-run       print the commands it would run, change nothing

The repo's shared git defaults (delta pager, etc.) live separately in
~/.config/git/config and are installed by ./install.sh — this only sets
the personal [user] identity those defaults leave out.
USAGE
      exit 0 ;;
    *) echo "unknown option: $1 (try --help)" >&2; exit 2 ;;
  esac
done

note()    { printf '  %s\n' "$*"; }
section() { printf '\n\033[1m%s\033[0m\n' "$1"; }
cur()     { git config --file "$GITCONFIG" --get "$1" 2>/dev/null || true; }

cur_name=$(cur user.name); cur_email=$(cur user.email); cur_key=$(cur user.signingkey)

if $SHOW; then
  section "Current git identity ($GITCONFIG)"
  note "user.name       = ${cur_name:-<unset>}"
  note "user.email      = ${cur_email:-<unset>}"
  note "user.signingkey = ${cur_key:-<unset>}"
  gpgsign=$(cur commit.gpgsign); [ -n "$gpgsign" ] && note "commit.gpgsign  = $gpgsign"
  exit 0
fi

# Resolve each field: explicit flag > interactive prompt (Enter keeps) > current.
ask() { # ask <label> <current> -> chosen value on stdout (prompt goes to the tty)
  local label="$1" current="$2" reply
  if [ -t 0 ] && ! $DRY_RUN; then
    read -r -p "  $label [${current:-none}]: " reply
    printf '%s' "${reply:-$current}"
  else
    printf '%s' "$current"
  fi
}

section "git identity → $GITCONFIG"
$DRY_RUN && note "(dry run — nothing is written)"

name=${opt_name:-$(ask "Your name" "$cur_name")}
email=${opt_email:-$(ask "Your email" "$cur_email")}
key=${opt_key:-$cur_key}   # signing key changes only via --signing-key, else kept

case "${email:-}" in ""|*@*.*) ;; *) note "⚠ '$email' doesn't look like an email — setting it anyway" ;; esac

# set_kv <key> <value> <label> — idempotent; skips empty and unchanged values.
set_kv() {
  local k="$1" v="$2" label="$3" current; current=$(cur "$k")
  [ -z "$v" ] && { note "skip $label (empty)"; return 0; }
  [ "$v" = "$current" ] && { note "ok   $label = $v (unchanged)"; return 0; }
  if $DRY_RUN; then note "would set $label → git config --file ~/.gitconfig $k \"$v\""
  else git config --file "$GITCONFIG" "$k" "$v"; note "set  $label = $v"; fi
}

set_kv user.name  "$name"  "user.name"
set_kv user.email "$email" "user.email"
if [ -n "$key" ]; then
  set_kv user.signingkey "$key"  "user.signingkey"
  set_kv commit.gpgsign  "true"  "commit.gpgsign"
fi

section "Done"
note "Identity is in ~/.gitconfig; the repo's shared defaults stay in ~/.config/git/config."
note "Verify: git config --get user.name · git config --get user.email   (re-run anytime to change)"
