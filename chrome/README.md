# 🌐 Chrome — the browser beside the stack

The stack lives in the terminal, but three jobs still happen in a browser: **reading docs**,
**learning from video**, and **checking the app you're building** — by hand or through Claude Code.
This guide sets Chrome up so those jobs stay keyboard-driven and close to the terminal: how to lay out
the windows, which settings and extensions earn their place, and — the part worth rereading — **which
tool to reach for when you hit a word or a paragraph you don't understand.**

- **Files:** this guide · `vimium-options.json` (your Vimium backup, restored by hand — see
  [§4](#4-vimium--the-keyboard-in-the-browser))
- **Install:** `google-chrome` is in the [`Brewfile`](../Brewfile)'s Personal section. Extensions and
  settings are set **by hand** — Chrome has no supported way to script them or export site-search
  shortcuts, so the tables below *are* the backup.

> ℹ️ **Not a stack layer.** Chrome is a separate app with its own keys — Vimium never shares a keystream
> with Ghostty, Zellij or Neovim, so nothing here can collide with the
> [keyboard-layer contract](../docs/guide.md#the-mental-model). Like [`cursor/`](../cursor/README.md),
> it's the tool you keep *next to* the terminal.

### Contents

1. [Two layouts](#1-two-layouts) — reading, and coding
2. [Setup](#2-setup) — profiles, settings, extensions
3. [Site-search shortcuts](#3-site-search-shortcuts) — `mdn`, `npm`, `gh`, `ts`, `yt` in the address bar
4. [Vimium](#4-vimium--the-keyboard-in-the-browser) — the keys, selecting text, YouTube
5. [Understand a word or a paragraph](#5-understand-a-word-or-a-paragraph) — the lookup ladder
6. [Claude in the browser](#6-claude-in-the-browser) — the side panel, and Claude Code's `--chrome`
7. [Routines](#7-routines) — docs, YouTube, a coding session

---

## 1. Two layouts

Window splits come from **[Raycast Window Management](https://manual.raycast.com/window-management)**
(Raycast is in the Brewfile). macOS's own tiling only does halves and quarters; Raycast adds thirds —
**First Two Thirds** and **Last Third** are the two commands both layouts use. Give them hotkeys in
Raycast (*Settings → Extensions → Window Management*); the repo doesn't pick them for you.

**Reading — learning a library, a spec, a course.**

```
┌─ Chrome · First Two Thirds ─────────────────────────┐┌─ Chrome · Last Third ────┐
│ vertical │                          │  Claude      ││  practice window          │
│ tabs     │   the docs page          │  side panel  ││  TS Playground,           │
│          │                          │  (/define,   ││  StackBlitz, a REPL…      │
│          │                          │   questions) ││                           │
└──────────┴──────────────────────────┴──────────────┘└───────────────────────────┘
```

Two Chrome windows: the docs with the Claude side panel on the left, a second window with a
playground on the right, where you try what you just read.

**Coding — building and checking an app.**

```
┌─ Chrome · First Two Thirds ─────────────────────────┐┌─ Ghostty · Last Third ────┐
│                                                     ││  Zellij: nvim │ claude     │
│   localhost:3000 — the app under test               ││  (or stack the two panes   │
│                                                     ││   vertically at this width)│
└─────────────────────────────────────────────────────┘└────────────────────────────┘
```

The app gets the space; the terminal keeps the editor and the agent. When Claude Code drives the
browser (`claude --chrome`, [§6](#6-claude-in-the-browser)) you watch it act in the left window while
the right one shows what it's doing.

## 2. Setup

### Profiles — Dev and Personal

Two [Chrome profiles](https://support.google.com/chrome/answer/2364824) keep work and life apart:
separate logins, history, extensions and tab sets.

| Profile | Holds | Extensions |
|---|---|---|
| **Dev** | GitHub, docs, localhost, work accounts | all four below |
| **Personal** | mail, YouTube, everything else | uBlock Origin Lite, Vimium, Google Dictionary |

**Why Claude in Chrome only in Dev:** Claude Code [shares the browser's login state](https://code.claude.com/docs/en/chrome)
— it can act on any site you're signed into. Keep that to the profile that holds your dev accounts.

### Settings

| Setting | Where | Value | Why |
|---|---|---|---|
| **Vertical tabs** | right-click the tab strip → *Show Tabs Vertically* | on | Long titles stay readable; a docs session with 15 tabs fits in the sidebar. |
| **Page zoom** | *Settings → Appearance → Page zoom* | 110–125% | Docs read better a size up; pick by screen. Per-site overrides stay on `⌘+` / `⌘-`. |
| **Memory Saver** | *Settings → Performance* | on | Frees memory from idle tabs — the terminal, Docker and the agent need it more. |
| **Preload pages** | *Settings → Performance* | on (standard) | Links you're likely to open load in the background — docs navigation feels instant. |
| **Bookmarks bar** | `⌘⇧B` | hidden | Bookmarks are a `b` away in Vimium ([§4](#4-vimium--the-keyboard-in-the-browser)); the bar is just height. |

Upstream: [Performance settings](https://support.google.com/chrome/answer/12929150) ·
[bookmarks bar](https://support.google.com/chrome/answer/188842).

### Extensions

| Extension | What it does here |
|---|---|
| [**Claude**](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) (Claude in Chrome) | The side panel for questions about a page, and the bridge Claude Code drives with `--chrome`. Needs a paid Claude plan. [§6](#6-claude-in-the-browser) |
| [**uBlock Origin Lite**](https://chromewebstore.google.com/detail/ublock-origin-lite/ddkjiahejlhfcafbddmgiahcphecmpfh) | Ad and tracker blocking. The original uBlock Origin is gone from the Chrome Web Store — Lite is what Chrome runs now. |
| [**Vimium**](https://chromewebstore.google.com/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb) | Vim keys for the browser — the same motions as Neovim. [§4](#4-vimium--the-keyboard-in-the-browser) |
| [**Google Dictionary (by Google)**](https://chromewebstore.google.com/detail/google-dictionary-by-goog/mgijmajocgfcbeboacabfgobmjgjcoja) | Double-click a word → a definition pop-up. In its options, set **your language**: foreign words are then translated into it (Russian is supported; Ukrainian isn't in its dictionary list). Optional lookup history, exportable to CSV — a ready-made vocabulary list. |

After installing Google Dictionary, **reload open tabs** — pages opened before the install don't get the
double-click pop-up.

## 3. Site-search shortcuts

Type a shortcut in the address bar, press **`Tab`**, type the query, `Enter` — you search that site
directly, skipping a search engine. Add each one in
*Settings → Search engine → Manage search engines and site search → Site search → Add*
([how](https://support.google.com/chrome/answer/95426)).

| Name | Shortcut | URL with `%s` in place of query |
|---|---|---|
| MDN | `mdn` | `https://developer.mozilla.org/en-US/search?q=%s` |
| npm | `npm` | `https://www.npmjs.com/search?q=%s` |
| GitHub | `gh` | `https://github.com/search?q=%s` |
| TypeScript docs | `ts` | `https://www.google.com/search?q=site:typescriptlang.org+%s` |
| YouTube | `yt` | `https://www.youtube.com/results?search_query=%s` |

**Why `ts` goes through Google:** typescriptlang.org has no search page a URL can reach, so a
`site:` search is the only way to land in its docs from the address bar.

Chrome **can't export or import** these, so this table is their only copy — add a row here when you
add a shortcut.

## 4. Vimium — the keyboard in the browser

[Vimium](https://github.com/philc/vimium) puts Vim motions on every page. `?` on any page shows the
full list; these are the ones that pay rent.

| Keys | Action | | Keys | Action |
|---|---|---|---|---|
| `j` / `k` | Scroll down / up | | `f` / `F` | Link hints — open here / in a new tab |
| `d` / `u` | Half page down / up | | `o` / `O` | Open URL, bookmark, history — here / new tab |
| `gg` / `G` | Top / bottom | | `T` | Search open tabs |
| `H` / `L` | Back / forward | | `J` / `K` | Previous / next tab |
| `/` · `n` / `N` | Find on page · next / previous match | | `x` / `X` | Close tab / restore it |
| `gi` | Focus the first input | | `yy` | Copy the page URL |
| `i` | Insert mode — Vimium ignores keys until `Esc` | | `b` / `B` | Bookmarks — here / new tab |

### Selecting text without the mouse

The path to a clean selection, e.g. to feed [§5](#5-understand-a-word-or-a-paragraph):

1. `/` → type a word near where you want to start → `Enter`. The match is now selected.
2. `v` → **visual mode**: the selection grows with `h`/`j`/`k`/`l`, `w`/`b`/`e`. `V` selects whole
   lines.
3. Need to move the start first? `c` (only inside visual mode) → **caret mode**: a cursor with no
   selection — move it, then `v` to start selecting from there.
4. `y` → copy the selection and leave visual mode.

If nothing is selected when you press `v`, Vimium drops you into caret mode on its own.

### YouTube — pass its keys through

YouTube has its own keys (`j`/`l` ±10 s, `k` play/pause, `f` fullscreen, `m` mute, `t` theater, `c`
captions), and Vimium takes several of them. An **exclusion rule** hands those keys back to the page
while keeping Vimium everywhere else on YouTube:

*Vimium Options → Excluded URLs and keys → Add rule*

| Patterns | Keys to exclude |
|---|---|
| `https?://www.youtube.com/*` | `jklfmt` |

**Why `jklfmt`, not more:** keys are one string of single characters, and Vimium strips spaces from it —
so `Space` can't be listed. It doesn't need to be: Vimium leaves `Space` and `c` unbound, so they
already reach YouTube. An empty *Keys* field would turn Vimium off on the site completely.
([wiki](https://github.com/philc/vimium/wiki/Disabling-Vimium))

### Backup and restore

Vimium keeps its settings (custom maps, exclusion rules, search engines) in the browser — they don't
survive a new machine on their own.

- **Back up:** *Vimium Options → Backup and Restore → Download backup* → save as
  `chrome/vimium-options.json` in this repo. **Read it before committing** — exclusion rules can name
  work domains, and this repo is public.
- **Restore:** *Vimium Options → Backup and Restore* → choose `vimium-options.json`.

## 5. Understand a word or a paragraph

Four tools, from cheapest to richest. **Take the first one that answers the question** — each step up
costs more time and attention.

| You hit… | Reach for | How |
|---|---|---|
| **One unfamiliar word** | Google Dictionary | Double-click it. Definition + translation into your language, no context switch. |
| **A phrase, an idiom, a technical term** | Claude, `/define` | Copy it (`v` … `y`, [§4](#selecting-text-without-the-mouse)), open the side panel, run `/define`, paste. Meaning in context, translation, an example — and for a term, a code sample. |
| **A paragraph that leans on another page** | Claude + a tab group | Put both tabs in Claude's tab group, then ask *"Explain this paragraph using the API reference in the other tab."* [§6](#tab-groups--questions-across-pages) |
| **A whole page in a language you read slowly** | Chrome Translate | Right-click → *Translate to …* (or select text → *Translate selection to …*). Fast and free; reach for Claude only when the translation loses the meaning. |

## 6. Claude in the browser

Two different things share the name, and they're used differently:

- **Claude in Chrome** — the extension's **side panel**: you ask about the page you're reading.
- **Claude Code with `--chrome`** — the **terminal agent** drives the browser through that extension:
  it opens your app, clicks, reads the console, and fixes the code.

### The side panel

Click the Claude icon in the toolbar; the panel stays open as you move between tabs and reads the tab
you're on. ([Getting started](https://support.claude.com/en/articles/12012173-getting-started-with-claude-in-chrome))

#### Tab groups — questions across pages

Drag tabs into **Claude's tab group** and Claude sees all of them at once — the docs page *and* the API
reference, the issue *and* the PR. That's what makes cross-page questions work without copying text
between them. Tabs Claude opens itself go into its own, differently coloured group.

#### Shortcuts — saved prompts

A prompt you reuse is saved as a **Shortcut**: type `/` in the panel and pick it. Edit or delete them in
the extension's settings; a clock icon in the panel schedules one to run on its own.

**The prompts live only in the extension** — logging out of it deletes them
([docs](https://code.claude.com/docs/en/chrome#extension-signed-in-to-a-different-organization)). The
text below is their backup; recreate them from here.

**`/define`** — set *Russian* to your language.

```text
Explain the text I paste below:
1. Plain-English meaning, in the context of this page.
2. Russian translation.
3. One usage example.
If it is a technical term, add a two-line explanation and a short code example.
```

**`/summarize-notes`** — page → notes ready to paste into Notion.

```text
Summarize this page as notes I can paste into Notion:
- a title line
- 3–5 key points, one sentence each
- code snippets worth keeping, as fenced code blocks
- the links I'd want to follow next
Markdown only, no preamble.
```

### Claude Code + Chrome

Run `claude --chrome` in the Claude pane; the agent then has browser tools and works in **visible tabs
in your Chrome**, signed in as you. Full reference: <https://code.claude.com/docs/en/chrome>.

| Need | Do |
|---|---|
| Browser for this session only | `claude --chrome` |
| Check the connection, re-connect, pick a browser | `/chrome` |
| Browser in every session | `/chrome` → **Enabled by default** |
| See every browser tool | `/mcp` → `claude-in-chrome` → *View tools* |

**Keep "Enabled by default" off.** With it on, the browser tools and their instructions load into every
session's context — even the ones that never open a page. Pass `--chrome` when the task needs a browser.

**Requirements:** the Claude extension 1.0.36 or later, a Pro / Max / Team / Enterprise plan, and Claude
Code signed in with `/login` (an API key doesn't work). If `/chrome` shows the extension *not
connected*: check the extension is signed in to the same account and organization as Claude Code, then
restart Chrome — the first connection needs it.

**Prompts that work well for testing your app** — say what to check, not just where to go:

```text
Open localhost:3000/signup, submit the form empty and then with an invalid email,
and tell me which error messages appear and where.
```

```text
Open localhost:3000/dashboard, reload it, and report any console errors.
Then find the code that throws them.
```

```text
Sign up on localhost:3000 as a new test user, then log out and back in.
Record a GIF of the whole flow.
```

## 7. Routines

### Learning from docs

1. Reading layout ([§1](#1-two-layouts)). Open the page with a site-search shortcut — `mdn fetch`,
   `ts satisfies`.
2. Read with `j`/`k`/`d`/`u`; open links in the background with `F`.
3. Stuck on a word or a paragraph → the lookup ladder ([§5](#5-understand-a-word-or-a-paragraph)).
4. Try each idea in the practice window before you move on.
5. Done → `/summarize-notes` → paste into Notion.

### Learning from YouTube

1. `yt <topic>` in the address bar. YouTube's own keys work thanks to the exclusion rule
   ([§4](#youtube--pass-its-keys-through)).
2. `c` for captions; a word you don't catch in them → double-click it (Google Dictionary).
3. Type along in the practice window or a terminal pane — `k` pauses, `j` rewinds 10 s.
4. `/summarize-notes` on the video page for the notes.

### A coding session

1. Coding layout ([§1](#1-two-layouts)): the app on the left, Zellij with `nvim │ claude --chrome` on
   the right.
2. Edit in Neovim; check the change in the browser yourself, or give Claude a test prompt
   ([§6](#claude-code--chrome)).
3. A console error → ask Claude to read the console and find the code, instead of copying the trace.
4. Docs needed mid-task → `mdn …` / `npm …` in a new tab, `x` to close it when done.
