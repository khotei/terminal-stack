-- Debug a package.json script under nvim-dap. lang.typescript already gives
-- "Launch file" + "Attach" (process pick) and auto-reads .vscode/launch.json;
-- the gap is launching `npm/pnpm run <script>` with the debugger attached.
-- Appended (never assigned) so lang.typescript's own configs survive — its block
-- guards with `if not dap.configurations[lang]`, so this spec must run after it
-- (user plugins load after extras) and add to the list, not replace it.
-- runtimeArgs is a function: nvim-dap evaluates function-valued config fields
-- when the config is run, so the script name is prompted at launch time.
-- https://github.com/mfussenegger/nvim-dap  ·  https://github.com/microsoft/vscode-js-debug
return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        local cfgs = dap.configurations[lang] or {}
        for _, runner in ipairs({ "npm", "pnpm" }) do
          table.insert(cfgs, {
            type = "pwa-node",
            request = "launch",
            name = "Debug " .. runner .. " script",
            runtimeExecutable = runner,
            runtimeArgs = function()
              return { "run", vim.fn.input(runner .. " script: ") }
            end,
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            skipFiles = { "<node_internals>/**" },
            sourceMaps = true,
          })
        end
        dap.configurations[lang] = cfgs
      end
    end,
  },
}
