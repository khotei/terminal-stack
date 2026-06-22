-- dropbar.nvim — IDE-style breadcrumb winbar (JetBrains "Context Info"): the
-- symbol path at the cursor, from LSP + treesitter. Passive/display-only — it
-- self-defers via its own plugin/dropbar.lua and only attaches the winbar where
-- a parser/LSP is present, so no lazy-load event and no keymap are needed.
-- Requires Neovim >= 0.11 (the stack satisfies this). https://github.com/Bekaboo/dropbar.nvim
return {
  { "Bekaboo/dropbar.nvim", opts = {} },
}
