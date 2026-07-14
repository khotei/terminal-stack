-- Gruvbox Material — the stack's shared palette, auto-switching with the OS:
-- light background in light appearance, dark in dark (Ghostty / Zellij / Starship
-- follow too). The colorscheme reads vim.o.background to pick light/dark.
-- https://github.com/sainnhe/gruvbox-material
-- The LazyVim-documented way to set a colorscheme: install the plugin, then point
-- LazyVim's `colorscheme` opt at it. https://www.lazyvim.org/configuration/general
return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.gruvbox_material_background = "medium" -- soft | medium | hard
      vim.g.gruvbox_material_better_performance = 1
    end,
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "gruvbox-material" } },
  -- Polls the macOS appearance and flips vim.o.background on change — works
  -- inside Zellij, where the terminal's CSI 2031 signal may not reach the editor.
  -- The hooks re-apply the colorscheme so it recompiles for the new mode.
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      set_dark_mode = function()
        vim.o.background = "dark"
        vim.cmd.colorscheme("gruvbox-material")
      end,
      set_light_mode = function()
        vim.o.background = "light"
        vim.cmd.colorscheme("gruvbox-material")
      end,
    },
  },
}
