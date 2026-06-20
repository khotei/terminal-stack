# terminal-stack — sandbox & validation entrypoints.
# The sandbox tests the in-terminal layers (Zellij / Neovim / zsh); Ghostty is a
# host GUI app and is not in the image. See docs/sandbox.md.
IMAGE ?= terminal-stack:dev

.PHONY: help build try zellij check check-local clean

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

clean: ## Remove the sandbox image
	-docker rmi $(IMAGE)
