# Worktrees

- Name every worktree for what it holds — `<ticket>-<step>-<topic>`, or `<topic>` outside a
  ticket — the folder and the branch alike. Never leave a hash or an agent id as the only name.
- When a tool picks the name (an agent started with `isolation: "worktree"` gets `agent-<id>`),
  add a symlink with the readable name beside the folder and rename the branch right after it is
  created. Never move or rename a folder while an agent works in it.
- While work spans several worktrees, every status names each item's worktree by its full
  readable path, so the user knows where to open lazygit.
- A worktree is a full, isolated environment: its own dependencies, `.env`, local data and
  containers, never a share of another tree's. When the project runs services, each worktree
  gets its own ports and container names (the project's docs say how), so worktrees run side
  by side without waiting for each other; stop a worktree's containers before removing it.
