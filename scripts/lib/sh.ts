// Thin wrappers over Bun's shell + filesystem so scripts read declaratively
// instead of spelling out `command -v` / `[ -L ]` / `readlink` each time.
import { lstat, readlink } from "node:fs/promises";
import { existsSync } from "node:fs";

// Is a binary on $PATH?  Bun.which returns the path or null — never throws.
export const has = (bin: string) => Bun.which(bin) !== null;

// Does a path exist (file, dir, or live symlink)?
export const exists = (path: string) => existsSync(path);

// The target of a symlink, WITHOUT following it — or null if it isn't a symlink
// (or doesn't exist). lstat (not stat) inspects the link itself.
export async function linkTarget(path: string): Promise<string | null> {
  try {
    const st = await lstat(path);
    return st.isSymbolicLink() ? await readlink(path) : null;
  } catch {
    return null;
  }
}
