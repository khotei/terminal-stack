-- glance.nvim — VS Code-style "peek" panel for LSP locations: read a definition or
-- every reference without leaving the buffer; <CR> in the panel jumps, q closes.
-- https://github.com/DNLHC/glance.nvim

-- The gp prefix mirrors the jump keys (gd/gr/gy/gI → gpd/gpr/gpy/gpi). Not glance's
-- suggested gD/gR/gY/gM: in TS buffers gD (source definition) and gR (file references)
-- are the typescript extra's. Cost: built-in `gp` (put, cursor after) now waits for
-- the timeout.
return {
  {
    "DNLHC/glance.nvim",
    cmd = "Glance",
    keys = {
      { "gpd", "<cmd>Glance definitions<cr>", desc = "Peek Definition" },
      { "gpr", "<cmd>Glance references<cr>", desc = "Peek References" },
      { "gpy", "<cmd>Glance type_definitions<cr>", desc = "Peek T[y]pe Definition" },
      { "gpi", "<cmd>Glance implementations<cr>", desc = "Peek Implementation" },
    },
    opts = {},
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "gp", group = "peek", icon = { icon = "󰈈 ", color = "blue" } },
      },
    },
  },
}
