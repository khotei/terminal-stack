return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Inlay hints off by default (LazyVim ships them on); <leader>uh reveals the
      -- rich set the vtsls settings below configure — JetBrains-style, on demand.
      inlay_hints = { enabled = false },
      servers = {
        vtsls = {
          settings = {
            -- .tsx reads `typescript`, .jsx reads `javascript` — mirror both.
            -- LazyVim's vtsls extra ships variableTypes off and parameterNames
            -- at "literals"; max both so a single <leader>uh reveals everything.
            typescript = {
              inlayHints = {
                variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
                parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
              },
            },
            javascript = {
              inlayHints = {
                variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
                parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
              },
            },
          },
        },
      },
    },
  },
}
