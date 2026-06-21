# 🛠️ scripts — the stack's tooling

Two kinds of script live here, by design:

| Kind | Files | Why this language |
|---|---|---|
| **Bootstrap-critical** (POSIX sh) | `entrypoint.sh`, `check.sh` · plus root `../bootstrap.sh`, `../install.sh`, `../claude/statusline.sh` | Must run on a **bare machine** (before any toolchain exists) or on a **hot path** (statusline renders every prompt). Zero runtime deps, universally legible. |
| **Bun TypeScript** | `doctor.ts`, `lib/*.ts` | Logic- and presentation-heavy scripts that run **after** the toolchain is installed (so `bun` exists). TypeScript reads cleaner, `parseArgs` gives flags for free, and the output is structured. |

The dividing line is **bootstrapping**: a script that installs the toolchain can't be written in a
language the toolchain provides. Everything downstream of that can. See the migration roadmap in the
PR that introduced this (`feat/bun-script-runtime`).

## The Bun scripts

```sh
bun scripts/doctor.ts        # or: make doctor   (zero install — bun reads .ts directly)
```

Bun runs the `.ts` files **directly** — no build step, no `node_modules` needed to run. The
`package.json`/`tsconfig.json` deps (`@types/bun`) are **dev-only**, for editor types and
`make typecheck` (`tsc --noEmit`).

### `lib/` — the shared foundation

| Module | Owns |
|---|---|
| [`lib/ui.ts`](lib/ui.ts) | Colours (`styleText`, gated on `NO_COLOR`) + the `✓ / ✗ / ↷ / !` status vocabulary + section headers. |
| [`lib/paths.ts`](lib/paths.ts) | `REPO` (from `import.meta.dir`), `HOME`, XDG `CONFIG`/`DATA`, `isMac`, `short()`. |
| [`lib/sh.ts`](lib/sh.ts) | `has()` (`Bun.which`), `exists()`, `linkTarget()` (lstat/readlink). |
| [`lib/cli.ts`](lib/cli.ts) | One `parseArgs` wrapper → uniform `-h/--help`, unknown-flag errors, `--dry-run`/`--prune`. |

A new script is `import` the lib, write the logic, done — the look, the paths, and the flags are
already solved.

## Validation

`make check` runs `bun build` over every `.ts` (a load check — syntax + imports), skipping where bun
is absent (e.g. CI). `make typecheck` runs the full `tsc` type check.

---

> Part of [terminal-stack](../README.md) · setup [install](../docs/install.md).
