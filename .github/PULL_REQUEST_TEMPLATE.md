## Summary
<!-- One paragraph (WHAT + WHY). The end state in plain language: what can you now do in the
terminal that you couldn't before, and why it was worth a config change. -->

## Feature & ACs covered
- **Feature:** <Notion Feature page URL> (`F-AREA-NNN`)
- **ACs:** AC-1, AC-… — one line each on how this PR satisfies them.

## What changed (annotated — per-setting rationale)
| File | Setting | Value | Why (cite upstream doc) |
|---|---|---|---|
| `path/to/file` | `key` | `value` | … · upstream-doc-url |

<!-- Never invent a config key — every row cites where the key is documented upstream. -->

## How to use / try it
<!-- Exact steps: where the file lives (~/.config/…), the reload step (Ghostty reload /
`:Lazy sync` / `source ~/.zshrc`), and the keypress or command that demonstrates it. -->

## Keybindings / cheatsheet
<!-- Include where the change adds or moves bindings. -->
| Keys | Action | Tool |
|---|---|---|
| `…` | … | … |

## Verification
<!-- The validators that prove the config loads (`/check`), with their output. -->
- `ghostty +show-config` → …
- `zellij setup --check` → …
- `nvim --headless "+checkhealth" +qa` → …

## References
- Upstream docs cited above.
- Related Feature / Research pages.

<!--
Author self-check (stripped at merge):
- [ ] Every new config key cited upstream — none invented
- [ ] `/check` green for every touched tool
- [ ] No keybinding collision with the multiplexer prefix / editor leader
- [ ] Cheatsheet / README updated
- [ ] Feature `PR` field set to this URL
Screenshots / asciinema (optional):
-->

Refs: <Notion Feature page URL> · Closes #<issue>
