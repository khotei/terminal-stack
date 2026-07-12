-- Catppuccin — the stack's shared palette, auto-switching with the OS: Latte in
-- light appearance, Mocha in dark (Ghostty / Zellij / Starship follow too).
-- flavour="auto" tracks vim.o.background (https://github.com/catppuccin/nvim).
-- The LazyVim-documented way to set a colorscheme: install the plugin, then point
-- LazyVim's `colorscheme` opt at it. https://www.lazyvim.org/configuration/general
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = { flavour = "auto", background = { light = "latte", dark = "mocha" } },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
  -- Polls the macOS appearance and flips vim.o.background on change — works
  -- inside Zellij, where the terminal's CSI 2031 signal may not reach the editor.
  -- The hooks re-apply catppuccin so flavour="auto" recompiles for the new mode.
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      set_dark_mode = function()
        vim.o.background = "dark"
        vim.cmd.colorscheme("catppuccin")
      end,
      set_light_mode = function()
        vim.o.background = "light"
        vim.cmd.colorscheme("catppuccin")
      end,
    },
  },
}
