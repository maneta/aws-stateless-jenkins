.PHONY: all build run bash push pull help
.DEFAULT_GOAL := help

NAME           = jenkins-exporter
NAMESPACE      = quay.io/3scale
VERSION       ?= $(shell  date +%y%m%d%H%M)

HOST_PORT      ?= 9118
CONTAINER_PORT ?= 9118

IMAGE_TAG    := $(VERSION)
LOCAL_IMAGE  := $(NAME):$(VERSION)
REMOTE_IMAGE := $(NAMESPACE)/$(NAME):$(IMAGE_TAG)

MKFILE_PATH  := $(abspath $(lastword $(MAKEFILE_LIST)))
THISDIR_PATH := $(patsubst %/,%,$(abspath $(dir $(MKFILE_PATH))))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))

all: build

update: build push ## Updates and push the Docker to the Registry. 

build: ## Build docker image with name LOCAL_IMAGE (NAME:VERSION).
	s2i build https://github.com/3scale/jenkins_exporter.git centos/python-27-centos7 $(LOCAL_IMAGE)

run: ## Run the docker in the local machine.
	docker run -p 9118:9118 -e APP_FILE=jenkins_exporter.py \
	-e JENKINS_SERVER=https://$(JENKINS_HOSTNAME) \
	-e JENKINS_USER=$(JENKINS_USER) \
	-e JENKINS_PASSWORD=$(JENKINS_TOKEN) \
	$(LOCAL_IMAGE)

bash: ## Start bash in the build IMAGE_NAME.
	docker run --rm -u 1000 --entrypoint=/bin/bash -it -p $(HOST_PORT):$(CONTAINER_PORT) -p 50000:50000 -v /tmp/jenkins:/var/jenkins_home $(LOCAL_IMAGE)

push: ## Push to the docker registry
	docker tag $(LOCAL_IMAGE) $(REMOTE_IMAGE)
	docker push $(REMOTE_IMAGE)

pull: ## Pull the docker from the Registry
	docker pull $(REMOTE_IMAGE)

# Check http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Print this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
