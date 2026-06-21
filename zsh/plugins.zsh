# zsh enhancement plugins — sourced LAST (.zshrc), syntax-highlighting must be the
# final load. Installed via Homebrew (brew bundle); each is guarded — a missing
# plugin is a silent skip, so it never breaks shell startup.

# Source each plugin from the first existing of: the Homebrew share dir, or a manual
# clone / test override under $ZSH_PLUGIN_DIR.
_share="$([ -d /opt/homebrew/share ] && echo /opt/homebrew/share || echo /usr/local/share)"
_pdir="${ZSH_PLUGIN_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins}"
_load() { local f="$1"; shift; local b; for b in "$@"; do [ -r "$b/$f" ] && { source "$b/$f"; return; }; done; }

# 1. Autosuggestions — grey inline suggestion from history; → (right arrow) accepts.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
_load zsh-autosuggestions.zsh "$_share/zsh-autosuggestions" "$_pdir/zsh-autosuggestions"

# 2. fzf-tab — Tab completion becomes an fzf picker. Homebrew installs it as
#    opt/fzf-tab/share/fzf-tab/fzf-tab.zsh (NOT under share/, and named *.zsh,
#    not *.plugin.zsh); a manual clone keeps the upstream *.plugin.zsh name.
for _ft in \
  /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh \
  /usr/local/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh \
  "$_share/fzf-tab/fzf-tab.zsh" \
  "$_pdir/fzf-tab/fzf-tab.plugin.zsh"; do
  [ -r "$_ft" ] && { source "$_ft"; break; }
done
unset _ft

# 3. Syntax highlighting — MUST be last; colours the command line as you type.
_load zsh-syntax-highlighting.zsh "$_share/zsh-syntax-highlighting" "$_pdir/zsh-syntax-highlighting"

unset -f _load; unset _share _pdir
