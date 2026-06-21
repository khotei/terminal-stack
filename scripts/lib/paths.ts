// Where things live. REPO is derived from this file's own location, so the
// scripts work no matter where the repo is cloned or which cwd invokes them
// (no `cd "$(dirname "$0")/.."` dance like the shell scripts needed).
import { homedir } from "node:os";
import { resolve } from "node:path";

export const HOME = homedir();
export const REPO = resolve(import.meta.dir, "..", ".."); // scripts/lib/ → repo root
export const CONFIG = process.env.XDG_CONFIG_HOME ?? `${HOME}/.config`;
export const DATA = process.env.XDG_DATA_HOME ?? `${HOME}/.local/share`;
export const isMac = process.platform === "darwin";

// ~-abbreviated path for tidy output (mirrors the shell `short()` helper).
export const short = (p: string) =>
  p.startsWith(HOME) ? `~${p.slice(HOME.length)}` : p;
