-- glance.nvim — JetBrains-style peek windows (Quick Definition / Show Usages):
-- inspect a definition/reference without leaving the buffer. Requires an attached
-- LSP, so it is inert until the lang.typescript extra (lazyvim.json) is on.
-- Peek lives on the `gp` namespace deliberately: `gD`/`gR` are owned by the TS
-- extra and `gd`/`gr` by the base LSP, so reusing them would collide. The only
-- default `gp` map is the rare built-in paste-and-move, an accepted tradeoff.
-- https://github.com/DNLHC/glance.nvim
return {
  {
    "dnlhc/glance.nvim",
    cmd = "Glance",
    keys = {
      { "gpd", "<cmd>Glance definitions<cr>", desc = "Peek: definitions" },
      { "gpr", "<cmd>Glance references<cr>", desc = "Peek: references" },
      { "gpt", "<cmd>Glance type_definitions<cr>", desc = "Peek: type definitions" },
      { "gpi", "<cmd>Glance implementations<cr>", desc = "Peek: implementations" },
    },
    opts = {},
  },
}
