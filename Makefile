
# ############################################################################ #
# Arguments
# ############################################################################ #

# Shell for makefile commands
SHELL=/bin/bash

export IMAGE?=node-dev

# Git tag info used for versioning
export TAG=$(shell git describe --tags)

# ############################################################################ #
# Targets
# ############################################################################ #

# Build the service images.
build:
	docker build \
		-t ${IMAGE} \
		.

## Build with multiplatform
buildx:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		-t ${IMAGE} \
		--push \
		.

## Push images
publish: build
	docker login
	docker push ${IMAGE}
	docker push ${IMAGE}:${TAG}

# Clean up build.
clean:
	@echo "Clean Build Services"
	docker-compose down --rmi local --remove-orphans

# Start up the containers
start:
	docker-compose up \
		--no-recreate \
		--no-build \
		--remove-orphans \
		--detach

# Stop all services. Wrap `docker-compose down`
stop:
	docker-compose down

# Start a shell.
sh: start
	docker-compose exec dev zsh

# Print version.
version:
	@echo ${TAG}

# ############################################################################ #
# Help
# ############################################################################ #

# Show this message.
help:
	@echo ""
	@echo "Usage: make <target>"
	@echo "Targets:"
	@grep -E "^[a-z,A-Z,0-9,-]+:.*" Makefile | sort | cut -d : -f 1 | xargs printf ' %s'
	@echo ""

.DEFAULT_GOAL=help
.PHONY:  build buildx clean help publish sh start stop version
