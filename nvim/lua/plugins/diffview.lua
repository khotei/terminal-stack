-- diffview.nvim — side-by-side diff + per-file history, for reviewing changes
-- (especially Claude Code's). `--imply-local` (default arg) puts the working-tree
-- file on the diff's RIGHT side, so LSP (gd/gr/diagnostics) works INSIDE the review,
-- not only after jumping to the real file. Ships no global keymaps, so we supply the
-- entry keys under the <leader>g git namespace. See ../../docs/reviewing-changes.md.
-- https://github.com/sindrets/diffview.nvim
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diff: working tree (review)" },
      { "<leader>gm", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diff: branch vs main (review)" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Diff: file history (cwd)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diff: current file history" },
    },
    opts = { default_args = { DiffviewOpen = { "--imply-local" } } },
  },
}
