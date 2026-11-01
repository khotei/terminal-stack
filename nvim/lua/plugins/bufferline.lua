return {
  -- Tabline shows TABPAGES, never buffers. bufferline in `mode = "tabs"` renders one entry per
  -- tabpage — so buffers stay hidden (we never use buffer mode) and the top bar is a true tab
  -- bar. LazyVim already sets always_show_bufferline = false, so the bar appears only at ≥2 tabs;
  -- a new tab (e.g. :DiffviewOpen) surfaces on its own. Switch tabs: gt/gT, {count}gt (jump by
  -- number), or <leader><tab>]/[. Rename a tab: :BufferLineTabRename (sets t:name).
  --
  -- bufferline derives its colours as 24-bit hex, which notermguicolors drops — every tab
  -- would draw alike. Slot numbers instead, so the bar follows Ghostty's palette
  -- (plugins/colorscheme.lua); bufferline keeps ctermfg keys when termguicolors is off.
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      local dim = { ctermfg = 8 }
      local selected = { ctermfg = 4, bold = true }
      local modified = { ctermfg = 3 }
      opts.options.mode = "tabs"
      opts.highlights = {
        background = dim,
        buffer_visible = dim,
        buffer_selected = selected,
        tab = dim,
        tab_selected = selected,
        tab_separator = dim,
        tab_separator_selected = dim,
        tab_close = dim,
        close_button = dim,
        close_button_visible = dim,
        close_button_selected = dim,
        separator = dim,
        separator_visible = dim,
        separator_selected = dim,
        indicator_visible = dim,
        indicator_selected = { ctermfg = 4 },
        modified = modified,
        modified_visible = modified,
        modified_selected = modified,
        duplicate = dim,
        duplicate_visible = dim,
        duplicate_selected = dim,
        numbers = dim,
        numbers_visible = dim,
        numbers_selected = selected,
        trunc_marker = dim,
      }
      for level, slot in pairs({ error = 1, warning = 3, info = 6, hint = 4 }) do
        for _, suffix in ipairs({
          "",
          "_visible",
          "_selected",
          "_diagnostic",
          "_diagnostic_visible",
          "_diagnostic_selected",
        }) do
          opts.highlights[level .. suffix] = { ctermfg = slot }
        end
      end
    end,
  },
}
