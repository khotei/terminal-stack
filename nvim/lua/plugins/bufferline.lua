return {
  -- Tabline shows TABPAGES, never buffers. bufferline in `mode = "tabs"` renders one entry per
  -- tabpage — so buffers stay hidden (we never use buffer mode) and the top bar is a true tab
  -- bar. LazyVim already sets always_show_bufferline = false, so the bar appears only at ≥2 tabs;
  -- a new tab (e.g. :DiffviewOpen) surfaces on its own. Switch tabs: gt/gT, {count}gt (jump by
  -- number), or <leader><tab>]/[. Rename a tab: :BufferLineTabRename (sets t:name).
  --
  -- Colors come from catppuccin, not bufferline's own derivation, so the bar follows light/dark.
  -- get_theme() returns a closure that reads the CURRENT flavour; bufferline re-invokes it on its
  -- own ColorScheme autocmd, so when auto-dark-mode (plugins/colorscheme.lua) flips background and
  -- re-applies catppuccin, the bar repaints Latte⇄Mocha instead of freezing on the startup flavour.
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.mode = "tabs"
      opts.highlights = require("catppuccin.special.bufferline").get_theme()
      return opts
    end,
  },
}
