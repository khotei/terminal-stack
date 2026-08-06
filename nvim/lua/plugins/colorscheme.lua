-- GitHub High Contrast — the Neovim port of the palette Ghostty loads. Anything drawing
-- real UI chrome needs its own port (Zellij, lazygit, delta, fzf, Claude Code — see
-- zsh/README.md §8); only bat, eza and Starship ride the ANSI slots for free. This one
-- is also the palette's canonical source: its primitives generate every other port.
-- High Contrast over Default: Default leaves WinSeparator and DiagnosticHint near
-- 1.1:1 — invisible. https://github.com/projekt0n/github-nvim-theme
-- The colorscheme sets vim.o.background itself, so the hooks below only name it.
return {
  { "projekt0n/github-nvim-theme", name = "github-theme", main = "github-theme", opts = {} },
  { "LazyVim/LazyVim", opts = { colorscheme = "github_dark_high_contrast" } },
  -- Polls the macOS appearance and re-applies the matching variant — works inside
  -- Zellij, where the terminal's CSI 2031 signal may not reach the editor.
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      set_dark_mode = function()
        vim.cmd.colorscheme("github_dark_high_contrast")
      end,
      set_light_mode = function()
        vim.cmd.colorscheme("github_light_high_contrast")
      end,
    },
  },
}
