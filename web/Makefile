# Variables
IMAGE_NAME = 3tier-web
GIT_IMAGE_TAG := $(CONTAINER_REGISTRY)/$(IMAGE_NAME):$(GIT_TAG)
LATEST_IMAGE_TAG := $(CONTAINER_REGISTRY)/$(IMAGE_NAME):latest

# Build the Docker image
.PHONY: build
build:
	docker build --platform=linux/amd64 -t $(IMAGE_NAME) .
	
.PHONY: push
push:
	docker tag $(IMAGE_NAME) $(GIT_IMAGE_TAG)
	docker tag $(IMAGE_NAME) $(LATEST_IMAGE_TAG)
	docker push $(GIT_IMAGE_TAG)
	docker push $(LATEST_IMAGE_TAG)
