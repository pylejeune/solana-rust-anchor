# Makefile for Solana/Anchor Development Environment

.PHONY: help build start stop exec clean ensure-key

CONTAINER_NAME = solana-dev-container
WORKDIR = /app
LOCAL_WORKDIR ?= $(shell pwd)
#SOLANA_KEYFILE ?= $(shell pwd)/.config/solana/id.json

# Include environment variables
-include .env


help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

ensure-key:  ## Ensure Solana keypair exists (run automatically before start)
	@if [ -f "$(SOLANA_KEYFILE)" ]; then \
		echo "Using existing Solana keypair at $(SOLANA_KEYFILE)";\
	else \
		echo  "No existing Solana Keypair at $(SOLANA_KEYFILE)"; \
		exit 1; \
	fi

build:  ## Build the development image
	@docker build -t $(DOCKER_IMAGE) . > /dev/null
	@echo "Image $(DOCKER_IMAGE) built successfully"

start: ensure-key  ## Start the development container with interactive shell
	@docker run -it --rm \
		--name $(CONTAINER_NAME) \
		-v $(LOCAL_WORKDIR):$(WORKDIR) \
		-v $(SOLANA_KEYFILE):/home/developer/.config/solana/id.json \
		-w $(WORKDIR) \
		-p 8899:8899 \
		-p 8900:8900 \
		$(DOCKER_IMAGE)

stop:  ## Stop the running container
	@docker stop $(CONTAINER_NAME) > /dev/null
	@echo "Container $(CONTAINER_NAME) stopped"

exec:  ## Execute a bash shell in the running container
	@docker exec -it $(CONTAINER_NAME) bash

clean:  ## Remove the Docker image
	@docker rmi $(DOCKER_IMAGE) > /dev/null
	@echo "Image $(DOCKER_IMAGE) removed"

start-detached: ensure-key  ## Start container in detached mode
	@docker run -d --rm \
		--name $(CONTAINER_NAME) \
		-v $(LOCAL_WORKDIR):$(WORKDIR) \
		-v $(SOLANA_KEYFILE):/home/developer/.config/solana/id.json \
		-w $(WORKDIR) \
		-p 8899:8899 \
		-p 8900:8900 \
		$(DOCKER_IMAGE) > /dev/null
	@echo "Container $(CONTAINER_NAME) started in detached mode"

test-anchor:  ## Test Anchor installation
	@docker run -it --rm \
		-v $(LOCAL_WORKDIR):$(WORKDIR) \
		-w $(WORKDIR) \
		$(DOCKER_IMAGE) \
		anchor --version

test-solana: ensure-key  ## Test Solana installation with keypair
	@docker run -it --rm \
		-v $(LOCAL_WORKDIR):$(WORKDIR) \
		-v $(SOLANA_KEYFILE):/home/developer/.config/solana/id.json \
		-w $(WORKDIR) \
		$(DOCKER_IMAGE) \
		bash -c "solana --version && solana address"

init-project:  ## Initialize a new Anchor project (set PROJECT_NAME=your-project)
	@docker run -it --rm \
		-v $(LOCAL_WORKDIR):$(WORKDIR) \
		-w $(WORKDIR) \
		$(DOCKER_IMAGE) \
		anchor init $(PROJECT_NAME)

fund-wallet: ensure-key  ## Fund the devnet wallet (requires .env with DEVNET_URL)
	@docker run -it --rm \
		-v $(SOLANA_KEYFILE):/home/developer/.config/solana/id.json \
		$(DOCKER_IMAGE) \
		bash -c "solana config set --url $(DEVNET_URL) && solana airdrop 5"