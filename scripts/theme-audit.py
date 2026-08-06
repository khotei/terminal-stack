#!/usr/bin/env python3
"""theme-audit.py — prove every colour in the hand-written themes is a real Primer token.

Six tools carry a hand-transcribed copy of GitHub High Contrast (Zellij, lazygit, Claude
Code, delta, fzf), because none of them can follow the terminal's palette on its own. A
transcribed hex is the one thing nothing else validates: Zellij, lazygit and Claude Code
all accept a wrong colour in silence. This walks each file and checks its hexes against
the Primer primitives that generate github-nvim-theme — the same source the editor uses,
so a typo or a drifted value fails here instead of showing up as an off-key pixel.

Run by scripts/check.sh; skips (exit 0) when github-theme isn't installed.
"""
import json, os, re, sys

REPO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DATA = os.environ.get("XDG_DATA_HOME") or os.path.expanduser("~/.local/share")
PRIM = f"{DATA}/nvim/lazy/github-theme/lua/github-theme/palette/primitives"


def primitives(mode):
    """Flatten one primitives file to a set of hexes, rgba tokens flattened over the canvas."""
    src = open(f"{PRIM}/{mode}_high_contrast.lua").read()
    tokens = json.loads(src[src.index("[=[") + 3: src.index("]=]")])

    flat = {}

    def walk(node, path=""):
        if isinstance(node, dict):
            for k, v in node.items():
                walk(v, f"{path}.{k}" if path else k)
        elif isinstance(node, str):
            flat[path] = node

    walk(tokens)
    canvas = [int(flat["canvas.default"][i:i + 2], 16) for i in (1, 3, 5)]
    out = set()
    for value in flat.values():
        if re.fullmatch(r"#[0-9a-fA-F]{6}", value):
            out.add(tuple(int(value[i:i + 2], 16) for i in (1, 3, 5)))
        elif value.startswith("rgba("):
            r, g, b, a = (float(x) for x in value[5:-1].split(","))
            out.add(tuple(c * a + bg * (1 - a) for c, bg in zip((r, g, b), canvas)))
    return out


def known(rgb, palette):
    """True if rgb is a palette token. Tolerance 1: an rgba token flattens to a fraction,
    and a half-value (34.5) can be transcribed either way round."""
    return any(max(abs(a - b) for a, b in zip(rgb, token)) <= 1 for token in palette)


def hexes(text):
    return [tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))
            for h in re.findall(r"#[0-9a-fA-F]{6}", text)]


def read(path):
    return open(os.path.join(REPO, path)).read()


def section(text, pattern):
    m = re.search(pattern, text, re.S)
    return m.group(1) if m else ""


def sources():
    """(label, [rgb…]) per file half — light and dark are checked against their own palette."""
    zellij = read("zellij/themes/github-high-contrast.kdl")
    git = read("git/config")
    fzf = re.findall(r"FZF_DEFAULT_OPTS='([^']*)'", read("zsh/theme.zsh"))
    for i, mode in enumerate(("light", "dark")):
        kdl = section(zellij, r"github-%s-hc\s*\{(.*?)\n    \}" % mode)
        yield mode, "zellij/themes/github-high-contrast.kdl", [
            tuple(int(x) for x in line.split()[1:])
            for line in kdl.splitlines()
            if len(line.split()) == 4 and all(x.isdigit() for x in line.split()[1:])
        ]
        yield mode, f"lazygit/theme-{mode}.yml", hexes(read(f"lazygit/theme-{mode}.yml"))
        yield mode, f"claude/themes/github-{mode}-high-contrast.json", hexes(
            read(f"claude/themes/github-{mode}-high-contrast.json"))
        yield mode, f'git/config [delta "github-{mode}"]', hexes(
            section(git, r'\[delta "github-%s"\](.*?)(?=\n\[|\Z)' % mode))
        yield mode, f"zsh/theme.zsh (fzf {mode})", hexes(fzf[i] if i < len(fzf) else "")


if not os.path.isdir(PRIM):
    print("  github-theme not installed — no primitives to check against")
    sys.exit(0)

palettes = {mode: primitives(mode) for mode in ("light", "dark")}
bad = 0
for mode, label, colours in sources():
    strays = sorted({c for c in colours if not known(c, palettes[mode])})
    if strays:
        bad += 1
        print(f"  {label}: not a Primer {mode} token — " +
              ", ".join("#%02x%02x%02x" % c for c in strays))
    else:
        print(f"  {label}: {len(set(colours))} colours, all Primer {mode}")
sys.exit(1 if bad else 0)
