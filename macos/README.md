# 💻 macOS defaults

Opinionated macOS **system** settings for a keyboard-first, Vim-heavy workflow — a `defaults write`
script in the spirit of [mathiasbynens/.macos](https://github.com/mathiasbynens/dotfiles/blob/main/.macos).

- **Script:** [`defaults.sh`](./defaults.sh)
- **Run:** `make macos` (or `./macos/defaults.sh`) · **preview:** `./macos/defaults.sh --dry-run`
- **Feature:** `F-META-012`

> ⚠️ This changes **system settings** (not symlinks). It's **opt-in** — `bootstrap.sh`/`install.sh`
> never run it. Every setting is reversible (below). Some need a **logout/restart** to take full
> effect. Always `--dry-run` first if unsure.

---

## What it sets

| Area | Setting | Why |
|---|---|---|
| **Dock** | `autohide` + fast slide, no recent apps, smaller icons | reclaim screen space; you launch via Raycast and switch via the keyboard |
| **Keyboard** | `ApplePressAndHoldEnabled = false` | **the Vim one** — holding a key (hjkl, x) **repeats** instead of popping the accent menu |
| | `KeyRepeat = 2`, `InitialKeyRepeat = 15` | fast repeat, short initial delay (tune lower = faster) |
| | `AppleKeyboardUIMode = 3` | full keyboard access — Tab reaches every control |
| **Trackpad** | tap-to-click, three-finger drag, two-finger secondary click | all the gestures, on the built-in **and** Bluetooth trackpad |
| **Shortcuts** | disable **Show Help menu** (`⌘⇧/`, hotkey 98) | it steals `⌘⇧/`; useless in a terminal/editor |
| | disable Terminal **Open man Page** (`⌘⇧M`) + **Search man Page Index** (`⌘⇧A`) services | they hijack those chords system-wide (e.g. fight JetBrains/editor binds) |

The two key/service ids are verified, not guessed: **hotkey 98** = *Show Help menu*; the man-page
[Services](https://developer.apple.com/documentation/appkit/services) live under `pbs NSServicesStatus`
as `openManPage` / `searchManPages`.

## Run it

```sh
make macos                      # apply
./macos/defaults.sh --dry-run   # preview every command, change nothing
```

Then **log out and back in** (or restart) so the key-repeat, the disabled hotkey, and the Services
changes fully register. The Dock/Finder/trackpad changes apply immediately (the script restarts Dock,
Finder, SystemUIServer).

## Reverting

Each setting is a `defaults` key — flip it back, or just toggle it in **System Settings**:

| Setting | Revert |
|---|---|
| Dock auto-hide | `defaults write com.apple.dock autohide -bool false && killall Dock` (or System Settings → Desktop & Dock) |
| Key repeat / press-and-hold | `defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool true` (then log out/in); reset rates in Settings → Keyboard |
| Trackpad gestures | toggle in System Settings → Trackpad, or `defaults delete` the keys above |
| Show Help menu | System Settings → Keyboard → Keyboard Shortcuts → App Shortcuts (re-enable), or `defaults delete com.apple.symbolichotkeys AppleSymbolicHotKeys` |
| man-page Services | System Settings → Keyboard → Keyboard Shortcuts → Services → Text, re-check them |

> A blunt full reset of one domain: `defaults delete com.apple.dock && killall Dock` (restores Dock
> defaults). Prefer the per-key reverts above for everything else.

---

> Part of [terminal-stack](../README.md) · usage [guide](../docs/guide.md) · setup [install](../docs/install.md).
