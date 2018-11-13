PROJECT = pageonex
DOCKER_REGISTRY ?= docker.io
DOCKER_ORG ?= pageonex
DOCKER_USERNAME ?=
DOCKER_PASSWORD ?=
VERSION ?= $(TRAVIS_TAG)

docker-login: docker-validate
	@docker login -u "$(DOCKER_USERNAME)" -p "$(DOCKER_PASSWORD)" $(DOCKER_REGISTRY); \

docker-validate:
	@if [ -z "$(DOCKER_USERNAME)" ]; then \
		echo "DOCKER_USERNAME variable cannot be empty."; \
		exit 1; \
	fi; \
	if [ -z "$(DOCKER_PASSWORD)" ]; then \
		echo "DOCKER_PASSWORD variable cannot be empty."; \
		exit 1; \
	fi

docker-build:
	@if [ -z "$(VERSION)" ]; then \
		echo "VERSION variable cannot be empty."; \
		exit 1; \
	fi; \
	if [ -z "$(DOCKER_ORG)" ]; then \
		echo "DOCKER_ORG variable cannot be empty."; \
		exit 1; \
	fi; \
	docker build -t $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(PROJECT):$(VERSION) .; \

docker-push: docker-login docker-build
	docker push $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(PROJECT):$(VERSION); \
	docker tag $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(PROJECT):$(VERSION) \
		$(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(PROJECT):latest; \
	docker push $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(PROJECT):latest;
