#!/usr/bin/env bash
# macOS defaults for terminal-stack — opinionated system settings for a
# keyboard-first, Vim-heavy workflow (mathiasbynens/.macos spirit).
#
# OPT-IN: bootstrap.sh / install.sh never run this — it changes SYSTEM settings,
# not symlinks. It is self-documenting: every setting prints a plain-English line
# of what it does as it runs, so if some behaviour on your Mac changes afterwards,
# you can trace it back to a line you saw. Each setting is reversible (macos/README.md);
# some need a logout/restart to fully apply.
#
# Usage:  ./macos/defaults.sh [--dry-run]   (or: make macos)
#   --dry-run  print the description + the exact command for every setting,
#              and change NOTHING.
set -uo pipefail

[ "$(uname -s)" = "Darwin" ] || { echo "macos/defaults.sh is macOS-only." >&2; exit 1; }

case "${1:-}" in
  --dry-run) DRY_RUN=true ;;
  -h|--help) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  "")        DRY_RUN=false ;;
  *)         echo "unknown option: $1 (try --help)" >&2; exit 2 ;;
esac

# apply "<what this does, in plain English>" <command…>
# Prints the human description (always), then runs the command — or, in --dry-run,
# prints the underlying command instead of running it.
apply() {
  local desc="$1"; shift
  printf '  \033[36m•\033[0m %s\n' "$desc"
  if $DRY_RUN; then printf '      \033[2m%s\033[0m\n' "$*"; else "$@"; fi
}
section() { printf '\n\033[1m%s\033[0m\n' "$1"; }

printf 'macOS defaults%s — every line below is a setting being changed.\n' \
  "$($DRY_RUN && printf ' (dry run — nothing is applied)')"
# Quit System Settings so it can't overwrite our changes when it next closes.
apply "Quit System Settings (so it won't overwrite these changes)" \
  osascript -e 'tell application "System Settings" to quit'

# ── Dock ──────────────────────────────────────────────────────────────
section "Dock"
apply "Dock auto-hides when a window needs the space (slides off-screen)" \
  defaults write com.apple.dock autohide -bool true
apply "Dock appears instantly when you hover the edge (no delay)" \
  defaults write com.apple.dock autohide-delay -float 0
apply "Dock show/hide slide is fast (0.15s)" \
  defaults write com.apple.dock autohide-time-modifier -float 0.15
apply "Dock won't show a 'recent apps' section" \
  defaults write com.apple.dock show-recents -bool false
apply "Dock icons are smaller (44px)" \
  defaults write com.apple.dock tilesize -int 44

# ── Menu bar ──────────────────────────────────────────────────────────
section "Menu bar"
apply "Menu bar auto-hides; slides back in when the pointer reaches the top edge" \
  defaults write NSGlobalDomain _HIHideMenuBar -bool true

# ── Desktop widgets ───────────────────────────────────────────────────
section "Desktop widgets"
apply "Hide desktop widgets (the Calendar/Weather/Photos cards on the wallpaper)" \
  defaults write com.apple.WindowManager StandardHideWidgets -bool true
apply "Hide desktop widgets in Stage Manager too" \
  defaults write com.apple.WindowManager StageManagerHideWidgets -bool true

# ── Keyboard — the Vim-critical settings ──────────────────────────────
section "Keyboard"
apply "Holding a key REPEATS it (off = the accent-picker popup; on = key repeat — needed for Vim hjkl/x)" \
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
apply "Key repeat is fast (rate 2; lower = faster)" \
  defaults write NSGlobalDomain KeyRepeat -int 2
apply "Short delay before a held key starts repeating (15)" \
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
apply "Tab moves between ALL controls in dialogs, not just text fields (full keyboard access)" \
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# ── Text — stop macOS 'helpfully' rewriting what you type (breaks code) ─
section "Text substitutions (off — they corrupt code & commands)"
apply "Don't turn straight quotes \" ' into curly “ ” ‘ ’ (curly quotes break code/JSON)" \
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
apply "Don't turn -- into an em-dash" \
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
apply "Don't auto-correct spelling as you type" \
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
apply "Don't auto-capitalize the first letter of a 'sentence'" \
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
apply "Don't insert a period when you type two spaces" \
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# ── Trackpad — all the gestures ───────────────────────────────────────
section "Trackpad"
apply "Tap to click (no need to press down)" \
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
apply "Tap to click — Bluetooth trackpad too" \
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
apply "Tap to click on the login screen + this host" \
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
apply "Tap to click — global flag" \
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
apply "Three-finger drag (move windows / select with 3 fingers)" \
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
apply "Three-finger drag — Bluetooth trackpad too" \
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
apply "Two-finger tap = right-click (secondary click)" \
  defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
apply "Two-finger right-click — Bluetooth trackpad too" \
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

# ── Finder — show what a developer needs to see ───────────────────────
section "Finder"
apply "Always show file extensions (.ts, .lock, …)" \
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
apply "Show hidden files (dotfiles) in Finder" \
  defaults write com.apple.finder AppleShowAllFiles -bool true
apply "Show the path bar at the bottom of every window" \
  defaults write com.apple.finder ShowPathbar -bool true
apply "Show the status bar (item count / free space)" \
  defaults write com.apple.finder ShowStatusBar -bool true
apply "New windows open in list view (Nlsv)" \
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
apply "Search defaults to the CURRENT folder, not the whole Mac (SCcf)" \
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
apply "Sort folders before files" \
  defaults write com.apple.finder _FXSortFoldersFirst -bool true
apply "No warning when you change a file extension" \
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
apply "Don't write .DS_Store files on network volumes" \
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
apply "Don't write .DS_Store files on USB volumes" \
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ── Screenshots ───────────────────────────────────────────────────────
section "Screenshots"
apply "Save screenshots to ~/Screenshots (not the cluttered Desktop)" \
  bash -c 'mkdir -p "$HOME/Screenshots"; defaults write com.apple.screencapture location -string "$HOME/Screenshots"'
apply "Save screenshots as PNG" \
  defaults write com.apple.screencapture type -string "png"
apply "No drop-shadow border around window screenshots" \
  defaults write com.apple.screencapture disable-shadow -bool true

# ── Speed — snappier UI ───────────────────────────────────────────────
section "UI speed"
apply "Windows resize almost instantly (animation 0.001s)" \
  defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
apply "No open/close window animations" \
  defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
apply "Faster Mission Control animation (0.1s)" \
  defaults write com.apple.dock expose-animation-duration -float 0.1
apply "Save/Print dialogs open in their expanded (detailed) state" \
  bash -c 'defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true; defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true'

# ── Security / friction ───────────────────────────────────────────────
section "Friction"
apply "No 'are you sure you want to open this app downloaded from the internet?' dialog" \
  defaults write com.apple.LaunchServices LSQuarantine -bool false

# ── Keyboard shortcuts that fight the terminal/Vim ────────────────────
section "Disabled shortcuts (freed for the terminal/Vim)"
apply "Disable 'Show Help menu' (⌘⇧/ — system hotkey 98; it steals that chord)" \
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 98 \
  "<dict><key>enabled</key><false/></dict>"
apply "Disable Terminal 'Open man Page' service (⌘⇧M)" \
  defaults write pbs NSServicesStatus -dict-add \
  '"com.apple.Terminal - Open man Page in Terminal - openManPage"' \
  '{ "enabled_context_menu" = 0; "enabled_services_menu" = 0; "presentation_modes" = { ContextMenu = 0; ServicesMenu = 0; }; }'
apply "Disable Terminal 'Search man Page Index' service (⌘⇧A — frees it for editors)" \
  defaults write pbs NSServicesStatus -dict-add \
  '"com.apple.Terminal - Search man Page Index in Terminal - searchManPages"' \
  '{ "enabled_context_menu" = 0; "enabled_services_menu" = 0; "presentation_modes" = { ContextMenu = 0; ServicesMenu = 0; }; }'

# ── Apply ─────────────────────────────────────────────────────────────
section "Restarting affected apps"
for app in Dock Finder SystemUIServer; do
  apply "Restart $app to pick up its changes" killall "$app"
done

printf '\n\033[32m✓ Done.\033[0m Log out/in (or restart) so the key-repeat, the disabled hotkey,\n'
printf '  the Services changes, and the menu-bar auto-hide fully register (_HIHideMenuBar is\n'
printf '  only re-read at login). Revert anything: see macos/README.md.\n'
