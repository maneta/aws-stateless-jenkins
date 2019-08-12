.PHONY: all build run bash push pull help
.DEFAULT_GOAL := help

ORIG_NAMESPACE = jenkins
NAME           = jenkins
NAMESPACE      = quay.io/3scale
VERSION       ?= 2.138.3
BUILD_VERSION ?= ${ENVIRONMENT}

HOST_PORT      ?= 443
CONTAINER_PORT ?= 443

IMAGE_TAG    := $(VERSION)-$(BUILD_VERSION)
LOCAL_IMAGE  := $(ORIG_NAMESPACE)/$(NAME):$(VERSION)
REMOTE_IMAGE := $(NAMESPACE)/$(NAME):$(IMAGE_TAG)

MKFILE_PATH  := $(abspath $(lastword $(MAKEFILE_LIST)))
THISDIR_PATH := $(patsubst %/,%,$(abspath $(dir $(MKFILE_PATH))))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))

GITHUB_TOKEN        ?= "@@Change_Me@@"
GITHUB_JENKINS_REPO ?= "github.com/3scale/sync-jenkins.git"

all: build

update: build push ## Updates and push the Docker to the Registry. 

build: ## Build docker image with name LOCAL_IMAGE (NAME:VERSION).
	docker build --no-cache -f $(THISDIR_PATH)/Dockerfile -t $(LOCAL_IMAGE) $(PROJECT_PATH) \
	--build-arg GITHUB_TOKEN=$(GITHUB_TOKEN) \
	--build-arg GITHUB_JENKINS_REPO=$(GITHUB_JENKINS_REPO)

run: ## Run the docker in the local machine.
	docker run --rm -u 1000 -it -e GIT_COMMITTER_NAME='Jenkins Run AutoCommit' -e GIT_COMMITTER_EMAIL='jenkins@3scale.com' -p $(HOST_PORT):$(CONTAINER_PORT) -p 50000:50000 -v /tmp/jenkins:/var/jenkins_home -v /tmp/builds:/var/builds -v /tmp/workspace:/var/workspace $(LOCAL_IMAGE) 

bash: ## Start bash in the build IMAGE_NAME.
	docker run --rm -u root --entrypoint=/bin/bash -it -p $(HOST_PORT):$(CONTAINER_PORT) -p 50000:50000 -v /tmp/jenkins:/var/jenkins_home $(LOCAL_IMAGE)

push: ## Push to the docker registry
	docker tag $(LOCAL_IMAGE) $(REMOTE_IMAGE)
	docker push $(REMOTE_IMAGE)

pull: ## Pull the docker from the Registry
	docker pull $(REMOTE_IMAGE)

# Check http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Print this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
