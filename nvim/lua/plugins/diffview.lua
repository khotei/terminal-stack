-- diffview.nvim — side-by-side diff + per-file history, for reviewing changes
-- (especially Claude Code's). Ships no global keymaps (its in-view binds are
-- buffer-local to the Diffview tabpage), so we supply the entry keys under the
-- existing `<leader>g` git namespace. https://github.com/sindrets/diffview.nvim
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diff: review changes (open)" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Diff: file history (cwd)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diff: current file history" },
    },
    opts = {},
  },
}
