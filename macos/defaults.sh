#!/usr/bin/env bash
# macOS defaults for terminal-stack — opinionated system settings for a
# keyboard-first, Vim-heavy workflow. OPT-IN (never run by bootstrap) because it
# changes system settings. Every setting is reversible; some need a logout or app
# restart to fully apply. Review it first, or preview with --dry-run.
#
# Usage:  ./macos/defaults.sh [--dry-run]   (or: make macos)
# Reference + how to revert each setting: macos/README.md
# Keys follow mathiasbynens/.macos; the hotkey/service ids are verified (see README).
set -uo pipefail

[ "$(uname -s)" = "Darwin" ] || { echo "macos/defaults.sh is macOS-only." >&2; exit 1; }

DRY_RUN=false
[ "${1:-}" = "--dry-run" ] && DRY_RUN=true
[ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && { sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

run() { if $DRY_RUN; then printf '  + %s\n' "$*"; else "$@"; fi; }
head() { printf '\n\033[1m%s\033[0m\n' "$1"; }

echo "macOS defaults → applying${DRY_RUN:+ (dry run — nothing changes)}"
# Quit System Settings so it can't overwrite our changes when it closes.
run osascript -e 'tell application "System Settings" to quit'

# ── Dock — auto-hide, fast, no clutter ────────────────────────────────
head "Dock"
run defaults write com.apple.dock autohide -bool true               # hide the Dock automatically
run defaults write com.apple.dock autohide-delay -float 0            # show instantly on hover
run defaults write com.apple.dock autohide-time-modifier -float 0.15 # fast slide
run defaults write com.apple.dock show-recents -bool false          # no recent-apps section
run defaults write com.apple.dock tilesize -int 44                  # smaller icons

# ── Keyboard — fast key-repeat for Vim (the important one) ────────────
head "Keyboard"
# Disable the press-and-hold accent popup so HOLDING a key repeats it (essential
# for held hjkl / x / dd in Vim). Then make the repeat fast.
run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
run defaults write NSGlobalDomain KeyRepeat -int 2                   # repeat rate (lower = faster)
run defaults write NSGlobalDomain InitialKeyRepeat -int 15           # delay before repeat (lower = shorter)
# Full keyboard access — Tab moves between ALL controls, not just text fields.
run defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# ── Trackpad — tap to click, three-finger drag, secondary click ───────
# Set both the built-in (AppleMultitouchTrackpad) and Bluetooth domains, plus the
# host-global flag the login window reads.
head "Trackpad"
run defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
run defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
run defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# Three-finger drag (move windows / select with three fingers).
run defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
# Two-finger secondary (right) click.
run defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

# ── Disable shortcuts that fight the terminal/Vim ─────────────────────
head "Conflicting shortcuts"
# "Show Help menu" (⌘⇧/) — system symbolic hotkey id 98.
run defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 98 \
  "<dict><key>enabled</key><false/></dict>"
# Terminal Services: "Open man Page" (⌘⇧M) and "Search man Page Index" (⌘⇧A) —
# they hijack those chords system-wide. Disable in both menus.
run defaults write pbs NSServicesStatus -dict-add \
  '"com.apple.Terminal - Open man Page in Terminal - openManPage"' \
  '{ "enabled_context_menu" = 0; "enabled_services_menu" = 0; "presentation_modes" = { ContextMenu = 0; ServicesMenu = 0; }; }'
run defaults write pbs NSServicesStatus -dict-add \
  '"com.apple.Terminal - Search man Page Index in Terminal - searchManPages"' \
  '{ "enabled_context_menu" = 0; "enabled_services_menu" = 0; "presentation_modes" = { ContextMenu = 0; ServicesMenu = 0; }; }'

# ── Apply ─────────────────────────────────────────────────────────────
head "Restarting affected apps"
for app in Dock Finder SystemUIServer; do run killall "$app"; done

printf '\n\033[32m✓ Done.\033[0m Log out/in (or restart) for the key-repeat, hotkey, and Services\n'
printf '  changes to fully take effect. Revert any setting: see macos/README.md.\n'
