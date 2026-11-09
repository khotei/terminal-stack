-- The lang.markdown extra pulls TWO renderers; we keep only the in-buffer one.
-- render-markdown.nvim draws headings/tables/code inline (<leader>um toggles
-- pretty ⇄ raw). markdown-preview.nvim is a *browser* live-preview — off by
-- choice in a terminal-first stack, which also drops its node build step.
-- https://www.lazyvim.org/extras/lang/markdown
--
-- markdownlint-cli2 finds a config only by name in the project root; a repo
-- that keeps it in .misc/lint/ (app-template) hands it over with --config, so
-- without the same flag here the editor lints with the defaults (width 80).
-- --no-globs: the config's globs would walk the whole repo on every lint
-- (~12 s); the editor lints one buffer.
local CONFIG = ".misc/lint/markdownlint-cli2.mjs"

-- The flags that apply the file's repo config, or {} when the repo has none.
local function config_args(path)
  local root = vim.fs.root(path, ".misc")
  local config = root and vim.fs.joinpath(root, CONFIG)
  if config and vim.uv.fs_stat(config) then
    return { "--config", config, "--no-globs" }
  end
  return {}
end

return {
  { "iamcco/markdown-preview.nvim", enabled = false },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        -- A function, so the config is looked up for each buffer linted.
        ["markdownlint-cli2"] = function()
          local linter = vim.deepcopy(require("lint.linters.markdownlint-cli2"))
          linter.args = vim.list_extend(config_args(0), linter.args)
          return linter
        end,
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        ["markdownlint-cli2"] = {
          prepend_args = function(_, ctx)
            return config_args(ctx.filename)
          end,
        },
      },
    },
  },
}
