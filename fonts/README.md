# 🅰️ Fonts

The primary typeface for the stack: **[Dank Mono](https://dank.sh)** — Regular, Italic, Bold.

`install.sh` copies these into the OS font directory on setup (`~/Library/Fonts` on macOS,
`~/.local/share/fonts` on Linux), **skipping any already installed**. They're *copied*, not symlinked,
so Font Book and other tools pick them up and a moved repo won't break them — which also means
`install.sh --prune` does not manage them.

Icon glyphs come from a **Nerd Font** (the Brewfile installs `font-symbols-only-nerd-font` and
`font-jetbrains-mono-nerd-font`); Dank Mono carries no icons, so Ghostty falls back to the Nerd Font
for those (see `../ghostty/config`).

## License

Dank Mono is a **commercial font** by Phil Pluckthun, purchased from <https://dank.sh>. The copy here
is the repository owner's licensed copy, kept for personal convenience. **Do not redistribute** — if
you want Dank Mono, buy your own license. Prefer a free typeface? Switch `ghostty/config`'s
`font-family` to `JetBrainsMono Nerd Font` (installed by the Brewfile) and skip this folder.
