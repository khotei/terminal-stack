return {
  -- Tabline off for good. showtabline = 0 (options.lua) isn't enough — bufferline re-enables
  -- the tab-bar on startup regardless, so disabling the plugin is the only reliable way to keep
  -- it hidden. Buffer cycling still works: LazyVim binds <S-h>/<S-l> and [b/]b to native
  -- :bprevious/:bnext in its own config/keymaps.lua, independent of this plugin. Only the
  -- bufferline-only <leader>b keys (pin/pick/close-left-right) go — and those need a visible bar.
  { "akinsho/bufferline.nvim", enabled = false },
}
