// Shared presentation layer for the Bun scripts — colours, status glyphs, sections.
// One owner for how every script looks, so doctor/check/(later)install read alike.
//
// Gating is Bun-native: `Bun.enableANSIColors` already folds in TTY detection,
// NO_COLOR (https://no-color.org) and FORCE_COLOR, so colour never leaks into a
// pipe/file and the user's environment is honoured — no hand-rolled check.
// We still apply styles with node:util `styleText`: Bun.color emits colour codes
// only (it returns null for `bold`/`dim` modifiers), and Bun has no styleText.
import { styleText } from "node:util";

const enabled = Bun.enableANSIColors;
type Format = Parameters<typeof styleText>[0];
const paint = (style: Format, s: string) => (enabled ? styleText(style, s) : s);

export const c = {
  bold: (s: string) => paint("bold", s),
  dim: (s: string) => paint("dim", s),
  red: (s: string) => paint("red", s),
  green: (s: string) => paint("green", s),
  yellow: (s: string) => paint("yellow", s),
  cyan: (s: string) => paint("cyan", s),
};

// The ✓ / ✗ / ↷ / ! status vocabulary, shared so every script speaks it the same.
//   ok   — good                      bad  — a problem, with the fix
//   soft — optional / not installed  warn — a soft issue (style, timeout)
export const ok = (msg: string) => console.log(`  ${c.green("✓")} ${msg}`);
export const bad = (label: string, hint: string) =>
  console.log(`  ${c.red("✗")} ${label}${c.dim(` — ${hint}`)}`);
export const soft = (label: string, why: string) =>
  console.log(`  ${c.yellow("↷")} ${label} ${c.dim(`(${why})`)}`);
export const warn = (msg: string) => console.log(`  ${c.yellow("!")} ${msg}`);
export const note = (msg: string) => console.log(`  ${msg}`);
export const section = (title: string) => console.log(`\n${c.bold(title)}`);
