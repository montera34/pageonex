# TODO: This is temporary, will need to adjust it when we connect to
# a proper CI
PROJECT = pageonex
DOCKER_REGISTRY = docker.io
DOCKER_ORG = pageonex
VERSION := $(TAG)
DOCKER_IMAGE = $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(PROJECT):$(VERSION)

docker-build:
	docker build -t $(DOCKER_IMAGE) .

docker-push: docker-build
	docker push $(DOCKER_IMAGE)
