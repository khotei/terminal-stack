-- One TS server per project: TypeScript 7's own `tsc --lsp` where the project pins
-- TS 7 (its patched tsc carries the Effect plugin, and only TS 7's symbol tree reaches
-- members built inside `extends Context.Service<…>()(…)`), vtsls everywhere else.
-- Both servers take the root lspconfig would: the nearest lockfile, else .git.
local ROOT_MARKERS = { { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }, { ".git" } }

local ts7_cache = {} ---@type table<string, boolean>

-- The project root when its node_modules/.bin/tsc is TypeScript 7+, else nil.
local function ts7_root(bufnr)
  local root = vim.fs.root(bufnr, ROOT_MARKERS)
  if not root then
    return nil
  end
  if ts7_cache[root] == nil then
    local bin = vim.fs.joinpath(root, "node_modules/.bin/tsc")
    local version = vim.fn.executable(bin) == 1
      and vim.version.parse(vim.system({ bin, "--version" }, { text = true }):wait().stdout or "")
    ts7_cache[root] = version and version.major >= 7 or false
  end
  return ts7_cache[root] and root or nil
end

-- lspconfig's own vtsls root_dir; read on first use, as the plugin isn't on the
-- runtimepath yet while specs load.
local vtsls_root_dir
local function vtsls_root(bufnr, on_dir)
  vtsls_root_dir = vtsls_root_dir or dofile(vim.api.nvim_get_runtime_file("lsp/vtsls.lua", false)[1]).root_dir
  vtsls_root_dir(bufnr, on_dir)
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Inlay hints off by default (LazyVim ships them on); <leader>uh reveals the
      -- rich set the server settings below configure — JetBrains-style, on demand.
      inlay_hints = { enabled = false },
      servers = {
        -- lang.typescript enables only one server; this turns tsc on beside vtsls.
        -- mason = false: the project's own binary runs, never a global TS 7.
        tsc = {
          enabled = true,
          mason = false,
          root_dir = function(bufnr, on_dir)
            local root = ts7_root(bufnr)
            if root then
              on_dir(root)
            end
          end,
          cmd = function(dispatchers, config)
            local bin = vim.fs.joinpath(config.root_dir, "node_modules/.bin/tsc")
            return vim.lsp.rpc.start({ bin, "--lsp", "--stdio" }, dispatchers)
          end,
          settings = {
            ["js/ts"] = {
              inlayHints = {
                parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
              },
            },
          },
        },
        vtsls = {
          root_dir = function(bufnr, on_dir)
            if not ts7_root(bufnr) then
              vtsls_root(bufnr, on_dir)
            end
          end,
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
