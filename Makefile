# terminal-stack — sandbox & validation entrypoints.
# The sandbox tests the in-terminal layers (Zellij / Neovim / zsh); Ghostty is a
# host GUI app and is not in the image. See docs/sandbox.md.
IMAGE ?= terminal-stack:dev

.PHONY: help build try zellij check check-local bootstrap install update macos git-setup clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

build: ## Build the sandbox image
	docker build -t $(IMAGE) .

try: build ## Interactive shell in the sandbox (repo mounted live at /work)
	docker run --rm -it -v "$(CURDIR)":/work $(IMAGE) zsh

zellij: build ## Jump straight into Zellij inside the sandbox
	docker run --rm -it -v "$(CURDIR)":/work $(IMAGE) zellij

check: build ## Run the validators inside the sandbox (Linux-accurate)
	docker run --rm -v "$(CURDIR)":/work $(IMAGE) bash scripts/check.sh

check-local: ## Run the validators on this machine (no Docker)
	bash scripts/check.sh

bootstrap: ## Fresh Mac → working stack (CLT + Homebrew + brew bundle + install)
	./bootstrap.sh

install: ## Symlink the configs into place (idempotent; --prune-aware via `make update`)
	./install.sh

doctor: ## Health-check: tools installed, configs symlinked, assets present (read-only)
	@bash scripts/doctor.sh

macos: ## Apply opinionated macOS system defaults (opt-in; preview: ./macos/defaults.sh --dry-run)
	./macos/defaults.sh

git-setup: ## Set your git identity (name/email) in ~/.gitconfig (interactive; --show/--dry-run)
	./git/setup.sh

update: ## Update everything: pull configs, install/upgrade tools, prune stale links
	git pull --ff-only
	brew update
	brew bundle --file=./Brewfile
	-brew upgrade --formula $$(brew bundle list --formula --file=./Brewfile)
	-brew upgrade --cask $$(brew bundle list --cask --file=./Brewfile)
	./install.sh --prune
	@echo ""
	@echo "→ open nvim, run :Lazy update, then commit nvim/lazy-lock.json to pin the new versions"

clean: ## Remove the sandbox image
	-docker rmi $(IMAGE)
