# Variables
CONTAINER_REGISTRY = 082168422974.dkr.ecr.ap-southeast-1.amazonaws.com
GIT_TAG:= $(shell git describe --always --dirty=-dirty)
export CONTAINER_REGISTRY
export GIT_TAG

# Default target
.PHONY: all
all: build

# Build all services
.PHONY: build
build: build-api build-web

# Build the API service
.PHONY: build-api
build-api:
	@echo "Building API Docker image..."
	$(MAKE) -C api build

# Build the Web service
.PHONY: build-web
build-web:
	@echo "Building Web Docker image..."
	$(MAKE) -C web build

.PHONY: push-web
push-web:
	@echo "Pushing API Docker image..."
	$(MAKE) -C web push

.PHONY: push-api
push-api:
	@echo "Pushing API Docker image..."
	$(MAKE) -C api push

.PHONY: push
push: push-api push-web