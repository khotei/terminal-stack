-- vim-wakatime — automatic time tracking, same account as the Claude Code
-- plugin, so editor + agent time land on one WakaTime dashboard. The API key
-- is NOT here: it lives in `~/.wakatime.cfg` (secret, public repo). lazy=false
-- per upstream — the plugin hooks Buf/Insert events at startup to time-stamp
-- activity; a deferred load would miss the first edits.
-- https://github.com/wakatime/vim-wakatime
return {
  { "wakatime/vim-wakatime", lazy = false },
}
