# terminal-stack — disposable Linux sandbox for the in-terminal layers.
# Ghostty is NOT here: it's a host GPU/GUI terminal and can't run in a container
# (only `ghostty +show-config` validates it, which scripts/check.sh notes-skips).
# What this image gives you: Zellij + Neovim + zsh + Starship + companion CLIs,
# so `make try` lets you exercise the multiplexer / editor / shell layers live.
#
# Build + run: see ./Makefile and ./docs/sandbox.md
FROM debian:bookworm-slim

# Companion CLIs + shell from apt (stable, no version pinning needed here).
# fd-find installs the binary as `fdfind`; we symlink it to `fd` (Debian rename).
RUN apt-get update && apt-get install -y --no-install-recommends \
        zsh git curl ca-certificates locales less \
        ripgrep fd-find fzf zoxide \
    && ln -sf "$(command -v fdfind)" /usr/local/bin/fd \
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen && locale-gen \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Neovim (stable release tarball) + Zellij (latest musl release) — arch-aware so
# the image builds natively on both amd64 and Apple-Silicon (arm64) hosts.
# Asset names verified against the upstream releases (see docs/sandbox.md §refs).
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) nvim_arch=x86_64; zj_arch=x86_64 ;; \
      arm64) nvim_arch=arm64;  zj_arch=aarch64 ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-${nvim_arch}.tar.gz" \
      | tar -xz -C /opt; \
    ln -s "/opt/nvim-linux-${nvim_arch}/bin/nvim" /usr/local/bin/nvim; \
    curl -fsSL "https://github.com/zellij-org/zellij/releases/latest/download/zellij-${zj_arch}-unknown-linux-musl.tar.gz" \
      | tar -xz -C /usr/local/bin zellij; \
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir /usr/local/bin

# Non-root user; zsh as the login shell. The repo is mounted at /work at runtime.
RUN useradd -m -s /usr/bin/zsh dev
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER dev
WORKDIR /work

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# Default: an interactive shell. Run `zellij` inside it to test the multiplexer.
CMD ["zsh"]
