#!/usr/bin/env bun
// doctor — "is my terminal-stack setup healthy?"  Read-only: it checks that the
// tools are installed, the configs are symlinked into place, and the bundled
// assets (fonts, autolock plugin) are present. It changes NOTHING. Run: make doctor
//
// Legend:  ✓ good   ✗ a problem (with the fix)   ↷ optional / not installed
import { c, ok, bad, soft, section } from "./lib/ui.ts";
import { has, exists, linkTarget } from "./lib/sh.ts";
import { REPO, CONFIG, HOME, DATA, isMac } from "./lib/paths.ts";
import { cli } from "./lib/cli.ts";

cli({
  name: "doctor",
  help: `doctor — is my terminal-stack setup healthy?
Read-only: tools installed, configs symlinked, assets present. Changes nothing.
Usage:  make doctor   ·   bun scripts/doctor.ts`,
});

let problems = 0;
const fail = (label: string, hint: string) => {
  bad(label, hint);
  problems++;
};

// tool(label, binary, hint-if-missing)  — `soft` downgrades a miss to optional.
function tool(label: string, bin: string, hint: string, opts: { soft?: boolean } = {}) {
  if (has(bin)) ok(`${label} (${bin})`);
  else if (opts.soft) soft(label, `${bin} not installed`);
  else fail(label, hint);
}

// linkcheck(label, path)  — expect a symlink (what install.sh creates).
async function linkcheck(label: string, path: string) {
  const target = await linkTarget(path);
  if (target !== null) ok(`${label} → ${target.replace(REPO, ".")}`);
  else if (exists(path)) soft(label, "exists but isn't our symlink");
  else fail(label, "missing — run ./install.sh");
}

console.log(`${c.bold("terminal-stack doctor")} — checking ${isMac ? "macOS" : process.platform} · ${REPO}`);

section("Tools — core (brew bundle)");
tool("Zellij", "zellij", "brew bundle (or brew install zellij)");
tool("Neovim", "nvim", "brew bundle");
tool("zsh", "zsh", "ships with macOS");
tool("Starship", "starship", "brew bundle");
tool("git", "git", "xcode-select --install / brew bundle");

section("Tools — companions");
tool("zoxide", "zoxide", "brew bundle");
tool("atuin", "atuin", "brew bundle");
tool("fzf", "fzf", "brew bundle");
tool("fd", "fd", "brew bundle");
tool("ripgrep", "rg", "brew bundle");
tool("lazygit", "lazygit", "brew bundle");
tool("yazi", "yazi", "brew bundle");
tool("jq", "jq", "brew bundle");
tool("eza", "eza", "brew bundle");
tool("bat", "bat", "brew bundle");
tool("delta", "delta", "brew bundle (git-delta)");

section("Tools — agent & terminal (casks)");
if (has("claude")) ok("Claude Code (claude)");
else fail("Claude Code", "brew bundle (cask claude-code), then run claude to log in");
if (has("ghostty") || exists("/Applications/Ghostty.app")) ok("Ghostty");
else soft("Ghostty", "host GUI app — brew bundle (cask), not needed in a sandbox");

section("Tools — validators (optional)");
tool("stylua", "stylua", "brew bundle", { soft: true });
tool("shfmt", "shfmt", "brew bundle", { soft: true });

section("Config symlinks (install.sh)");
await linkcheck("Ghostty config", `${CONFIG}/ghostty/config`);
await linkcheck("Zellij", `${CONFIG}/zellij`);
await linkcheck("Neovim", `${CONFIG}/nvim`);
await linkcheck(".zshrc", `${HOME}/.zshrc`);
await linkcheck("zsh role files", `${CONFIG}/zsh/env.zsh`);
await linkcheck("Starship", `${CONFIG}/starship.toml`);
await linkcheck("git config", `${CONFIG}/git/config`);
await linkcheck("Claude statusline", `${HOME}/.claude/statusline.sh`);
await linkcheck("cc-worktree", `${HOME}/.local/bin/cc-worktree`);

section("Bundled assets");
const fontDir = isMac ? `${HOME}/Library/Fonts` : `${DATA}/fonts`;
if (exists(`${fontDir}/DankMono-Regular.otf`)) ok("Dank Mono font installed");
else soft("Dank Mono font", "run ./install.sh; or use JetBrainsMono Nerd Font");
if (exists(`${CONFIG}/zellij/plugins/zellij-autolock.wasm`)) ok("zellij-autolock plugin");
else soft("zellij-autolock plugin", "fetched by ./install.sh; autolock stays inert without it");
const onPath = (process.env.PATH ?? "").split(":").includes(`${HOME}/.local/bin`);
if (onPath) ok("~/.local/bin on $PATH");
else fail("PATH", "~/.local/bin not on $PATH — cc-worktree won't be found; add it in zsh/env.zsh");

section("Verdict");
if (problems === 0) console.log(`${c.green("✓ Healthy.")} Validate config contents with: make check`);
else console.log(`${c.red(`✗ ${problems} problem(s) above.`)} Fix per the hints, then re-run: make doctor`);
process.exit(problems === 0 ? 0 : 1);
