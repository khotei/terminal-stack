# Vi mode for the command line — jeffreytse/zsh-vi-mode.
# Esc → normal mode, text objects, surround, a mode indicator + cursor shape.
# Install: `brew install zsh-vi-mode` (it's in the Brewfile). https://github.com/jeffreytse/zsh-vi-mode

# Init at SOURCING time (not the first prompt) so plugins loaded after this file —
# fzf/atuin in tools.zsh — keep their keybindings instead of being clobbered when
# zvm rebinds the keymaps. This is why .zshrc sources vi-mode before tools.
ZVM_INIT_MODE=sourcing

# Find the plugin: an explicit $ZVM_PLUGIN, the Homebrew opt path (Apple Silicon /
# Intel), or a manual clone under ~/.config/zsh/plugins. A missing plugin is a
# silent skip — it must never break shell startup.
_zvm_paths=(
  "${ZVM_PLUGIN:-}"
  "/opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
  "/usr/local/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
  "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
)
for _p in "${_zvm_paths[@]}"; do
  [ -n "$_p" ] && [ -r "$_p" ] && { source "$_p"; break; }
done
unset _zvm_paths _p
