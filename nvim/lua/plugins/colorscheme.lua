-- Catppuccin Mocha — the stack's shared palette (Ghostty / Zellij / Starship match).
-- The LazyVim-documented way to set a colorscheme: install the plugin, then point
-- LazyVim's `colorscheme` opt at it. https://www.lazyvim.org/configuration/general
return {
  { "catppuccin/nvim", name = "catppuccin", opts = { flavour = "mocha" } },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
