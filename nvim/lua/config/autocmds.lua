-- Autocmds are automatically loaded on the VeryLazy event
-- Default LazyVim autocmds:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here.

-- Scope-dimming on by default. Snacks `dim` isn't a LazyVim default — it's activated by a
-- call, not an option, and `Snacks` isn't defined yet when this file loads, so defer to
-- VeryLazy. Toggle per-session with <leader>uD.
LazyVim.on_very_lazy(function()
  Snacks.dim.enable()
end)
