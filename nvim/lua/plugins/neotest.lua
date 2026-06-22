-- neotest adapters — test.core ships neotest with an empty adapters table, and
-- LazyVim's lang.typescript adds none, so the TS adapters must be supplied here
-- or no tests are discovered. Both coexist: neotest picks the right one per
-- project, so the stack works whether a repo uses Vitest or Jest.
-- vitest registers by name; jest by a called setup fn — neotest's two documented
-- forms. Merge into (don't replace) LazyVim's opts.adapters.
-- https://github.com/nvim-neotest/neotest
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-jest",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      opts.adapters["neotest-vitest"] = {}
      table.insert(opts.adapters, require("neotest-jest")({}))
      return opts
    end,
  },
}
