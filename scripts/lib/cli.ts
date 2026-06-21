// Uniform flag parsing + `--help` for every script. Wraps node:util parseArgs
// (stable since Node 20, supported by Bun) so a script declares its flags once
// and gets `-h/--help`, unknown-flag errors, and `--dry-run`/`--prune` for free.
import { parseArgs } from "node:util";
import type { ParseArgsConfig } from "node:util";

type Options = NonNullable<ParseArgsConfig["options"]>;
type Values = Record<string, boolean | string | (boolean | string)[] | undefined>;

export function cli(spec: {
  name: string;
  help: string;
  options?: Options;
  allowPositionals?: boolean;
}): { values: Values; positionals: string[] } {
  // `help` is injected for every script; a script's own flags extend it.
  const options: Options = { help: { type: "boolean", short: "h" }, ...spec.options };
  try {
    const { values, positionals } = parseArgs({
      args: Bun.argv.slice(2),
      options,
      allowPositionals: spec.allowPositionals ?? false,
    });
    if (values.help) {
      console.log(spec.help.trim());
      process.exit(0);
    }
    return { values: values as Values, positionals };
  } catch (err) {
    console.error(`${spec.name}: ${(err as Error).message} (try --help)`);
    process.exit(2);
  }
}
