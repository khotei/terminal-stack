// Shared presentation layer for the Bun scripts — colours, status glyphs, sections.
// One owner for how every script looks, so doctor/check/(later)install read alike.
//
// Colour is on unless NO_COLOR is set (https://no-color.org). We gate it ourselves
// rather than relying on TTY detection, matching the shell scripts (which always
// colour) while still honouring the one universal opt-out.
import { styleText } from "node:util";

const enabled = !("NO_COLOR" in process.env);
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
