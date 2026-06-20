<!-- Generated from the Terminal Stack SDD hub §4 — https://app.notion.com/p/385fb28bd5f1810d91ddd69ea4c49243. Re-sync on change. -->

# Notion data-source IDs (for the `/sdd:*` commands)

The `sdd:*` commands write rows/pages into these databases via the Notion MCP. Creating a
page needs the **`collection://` data-source ID** (the page URL is not enough). These IDs are
stable, so they are **embedded** here and `@`-referenced by the commands — never fetched at run
time (the §5 embed-vs-link rule). Only the *content* (specs to cite, current max ID, the
feature/task body) is fetched live.

| Database | What `/sdd:*` does with it | Page URL | Data-source ID |
|---|---|---|---|
| **Features** | `/sdd:specify` creates the Feature row; `/sdd:plan` / `/sdd:verify` update it | https://app.notion.com/p/b87cb79f03884366bf357ae2c0407c7d | `collection://ccc5e404-fe53-4d77-b153-6fa2250b0ea3` |
| **Tasks** | `/sdd:tasks` creates the task rows (the board view *is* the kanban) | https://app.notion.com/p/09df2c45b34a4b66bb158c02cdd58ca6 | `collection://4c0c6c0e-f896-4621-a655-9e0b4bce7443` |
| **Specs** | `/sdd:research` creates a Research-findings page (Doc type = Research) | https://app.notion.com/p/4168251023ff48a0b08ec66438963eee | `collection://39776910-bc04-432f-ba8c-61671ba366c2` |

## Anchor pages

- **SDD hub / playbook (the authored source these commands compile):** https://app.notion.com/p/385fb28bd5f1810d91ddd69ea4c49243

## Notes

- To scope a `notion-search` to one database, pass its `collection://` ID as the search scope —
  avoids cross-database noise when looking up the current max Feature/Task ID.
- These IDs only change if a database is recreated. If a write fails with "unknown data source",
  re-confirm the ID from the Terminal Stack SDD hub before editing here.
- There is **no** separate Templates DB and **no** Sprints DB — the scaffolds the commands compile
  from live in the hub itself; tasks are scheduled by `Status`, not by a Sprint relation.
