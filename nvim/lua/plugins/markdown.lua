-- The lang.markdown extra pulls TWO renderers; we keep only the in-buffer one.
-- render-markdown.nvim draws headings/tables/code inline (<leader>um toggles
-- pretty ⇄ raw). markdown-preview.nvim is a *browser* live-preview — off by
-- choice in a terminal-first stack, which also drops its node build step.
-- https://www.lazyvim.org/extras/lang/markdown
return {
  { "iamcco/markdown-preview.nvim", enabled = false },
}
