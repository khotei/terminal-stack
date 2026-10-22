# Worktrees

- Name every worktree for what it holds — `<ticket>-<step>-<topic>`, or `<topic>` outside a
  ticket — the folder and the branch alike. Never leave a hash or an agent id as the only name.
- When a tool picks the name (an agent started with `isolation: "worktree"` gets `agent-<id>`),
  add a symlink with the readable name beside the folder and rename the branch right after it is
  created. Never move or rename a folder while an agent works in it.
- While work spans several worktrees, every status names each item's worktree by its full
  readable path, so the user knows where to open lazygit.
