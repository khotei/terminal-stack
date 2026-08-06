return {
  -- Tabline shows TABPAGES, never buffers. bufferline in `mode = "tabs"` renders one entry per
  -- tabpage — so buffers stay hidden (we never use buffer mode) and the top bar is a true tab
  -- bar. LazyVim already sets always_show_bufferline = false, so the bar appears only at ≥2 tabs;
  -- a new tab (e.g. :DiffviewOpen) surfaces on its own. Switch tabs: gt/gT, {count}gt (jump by
  -- number), or <leader><tab>]/[. Rename a tab: :BufferLineTabRename (sets t:name).
  --
  -- No highlight override: bufferline derives its colours from the active colorscheme and
  -- re-derives them on its own ColorScheme autocmd, so the bar follows the light/dark flip
  -- in plugins/colorscheme.lua without a theme-specific integration module.
  {
    "akinsho/bufferline.nvim",
    opts = { options = { mode = "tabs" } },
  },
}
