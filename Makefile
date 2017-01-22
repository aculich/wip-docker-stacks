default: test

# Build Docker image
build: docker_build output

# Build and push Docker image
release: docker_build docker_push output

# Image can be overidden with env vars.
WIP_IMAGE ?= wip
DOCKER_IMAGE ?= aculich/wip
CONTAINER_NAME ?= wip

JUPYTER_INSECURE = start-notebook.sh --NotebookApp.token=''
COMMAND ?= $(JUPYTER_INSECURE)
WORKDIR ?= /home/jovyan/work

# Get the latest commit.
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

# Get the version number from the code
CODE_VERSION = $(strip $(shell cat VERSION))

# Find out if the working directory is clean
GIT_NOT_CLEAN_CHECK = $(shell git status --porcelain)
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
DOCKER_TAG_SUFFIX = "-dirty"
endif

# If we're releasing to Docker Hub, and we're going to mark it with the latest tag, it should exactly match a version release
ifeq ($(MAKECMDGOALS),release)
# Use the version number as the release tag.
DOCKER_TAG = $(CODE_VERSION)

ifndef CODE_VERSION
$(error You need to create a VERSION file to build a release)
endif

# See what commit is tagged to match the version
VERSION_COMMIT = $(strip $(shell git rev-list $(CODE_VERSION) -n 1 | cut -c1-7))
ifneq ($(VERSION_COMMIT), $(GIT_COMMIT))
$(error echo You are trying to push a build based on commit $(GIT_COMMIT) but the tagged release version is $(VERSION_COMMIT))
endif

# Don't push to Docker Hub if this isn't a clean repo
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
$(error echo You are trying to release a build based on a dirty repo)
endif

else
# Add the commit ref for development builds. Mark as dirty if the working directory isn't clean
DOCKER_TAG = $(CODE_VERSION)-$(GIT_COMMIT)$(DOCKER_TAG_SUFFIX)
endif

test: docker_build test-only
test-only:
	docker rm -f $(CONTAINER_NAME) || true
	docker run --name $(CONTAINER_NAME) -p 8888:8888 -v$(shell dirname $(shell pwd)):$(WORKDIR) -e GRANT_SUDO=yes  -d $(WIP_IMAGE):$(DOCKER_TAG) $(COMMAND)
	docker ps

shell:
	docker exec -it $(CONTAINER_NAME) /bin/bash

build docker_build: $(SOURCES)
	docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VERSION=$(CODE_VERSION) \
  --build-arg VCS_URL=`git config --get remote.origin.url` \
  --build-arg VCS_REF=$(GIT_COMMIT) \
	-t $(WIP_IMAGE):$(DOCKER_TAG) .

push docker_push:
	docker tag $(WIP_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):latest

output:
	@echo Docker Image: $(WIP_IMAGE):$(DOCKER_IMAGE):$(DOCKER_TAG)
