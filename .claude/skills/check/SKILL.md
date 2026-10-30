---
name: check
description: Validate the stack's config files (Ghostty, Zellij, Neovim, zsh) and report failures
---

Run `bash scripts/check.sh` from the repo root and report its result concisely. The script is the
one list of validators — the same one `make check`, `make check-local` and CI run — so don't run
the validators one by one, and don't add steps here; a new validator goes into the script.

- Report each section's **PASS / FAIL / SKIP** line as the script prints it. A SKIP means the tool
  isn't installed on this machine; it is not a failure.
- On FAIL, show the specific error (file:line + message) and stop — do not attempt fixes unless
  asked.
- A style warning (`stylua`, `shfmt`) is a soft fail: name the fix command the script prints.
- When you touched one Neovim module and want a faster signal than the full load, also run
  `nvim --headless -c 'luafile <file>' -c qa`.
- If everything passes (or is cleanly skipped), say so in one line.

For the Linux-accurate run inside the sandbox image, use `make check` (`docs/sandbox.md`).
