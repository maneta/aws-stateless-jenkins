PHONY: create_plugins_file create_bucket create_environment_dir create_config pull push help
.DEFAULT_GOAL := help
SHELL = /bin/bash

#Including Default Variables
include ./templates/makefile-defaults.mk

#Including Makefile with Terraform operations
include ./lib/terraform-operations.mk

#Including Makefile with shell-detection
include ./lib/shell-detection.mk

#Including Makefile with some pre-tasks running before any target
include ./lib/pre-checks.mk

#Including Makefile with variables export
include ./lib/variables-export.mk

#Including Makefile with Environment operations
include ./lib/environment-operations.mk

#Default Terrafor Version
TERRAFORM_VERSION ?= 0.10.8

#Calculating Quay Token
DOCKER_AUTH_TOKEN = $(shell printf "%s:%s" ${DOCKER_USER} ${DOCKER_PASSWORD} | ${BASE64})

environment_create: create_environment_dir create_config create_bucket ## Create Jenkins Environment Files

environment_generate: terraform_generate_environment terraform_generate_backend_config push ## Generates Terraform Jenkins Environment

environment_plan: FORCE=true
environment_plan: terraform_generate_environment terraform_plan ## Regenerate TF Files and plan

environment_apply: FORCE=true
environment_apply: terraform_generate_environment terraform_apply push ## Apply Environmet Changes

create_config: # Create the Configuration Files needed to the deploy the Cluster on AWS and uploads it to the Cluster S3 Bucket. Parameters: FORCE={true|false default} Force Configuration regeneration and uploads it to S3.
	@echo "[INFO] - Generating Config file ./environments/${ENVIRONMENT}/config.mk"
	@if [ ! -f ./environments/${ENVIRONMENT}/config.mk ] || [ ${FORCE} == "true" ] ; then \
		ENVIRONMENT=${ENVIRONMENT} \
		R53_PARENT_ZONE_DOMAIN_NAME=$(patsubst %.,%,$(shell aws route53 get-hosted-zone --id ${R53_PARENT_ZONE_ID} --query 'HostedZone.Name' --output text)) \
		DOCKER_AUTH_TOKEN=${DOCKER_AUTH_TOKEN} \
		envtpl < ./templates/config.mk.tpl > ./environments/${ENVIRONMENT}/config.mk ; \
	else \
		echo "config already exists, use FORCE=true if you want to overwrite"; \
		exit 1; \
	fi

create_plugins_file: # Retrieves the list of plugins on the deployed version of Jenkins
	@echo "[INFO] - Generating plugins.txt File"
	@if [ ! -f ./templates/${ENVIRONMENT}-plugins.txt ] || [ ${FORCE} == "true" ] ; then \
		curl -u ${JENKINS_USER}:${JENKINS_TOKEN} -s -k "https://${JENKINS_HOSTNAME}/pluginManager/api/json?depth=1" | jq '.plugins[]|{shortName, version}|"\(.shortName):\(.version)"' -r | sort -f > ./templates/${ENVIRONMENT}-plugins.txt;\
		echo "[INFO] - File Generated: plugins.txt";\
	else \
		echo "Plugins File already exists, use FORCE=true if you want to overwrite"; \
		exit 1; \
	fi

generate_keystore: # Generates Jenkins SSL Keystore
	@echo "[INFO] - Generating keystore File"
	@if [ ! -f  ./environments/${ENVIRONMENT}/certs/keystore ] || [ ${FORCE} == "true" ] ; then \
		cd ./environments/${ENVIRONMENT}/certs/ && \
		rm -f keystore && \
		openssl pkcs12 -inkey cert.key -in cert.crt -export -out keys.encrypted.pkcs12 -passout pass:jenkins && \
		yes jenkins | keytool -importkeystore -srckeystore keys.encrypted.pkcs12 -srcstoretype pkcs12 -destkeystore keystore;\
		echo "[INFO] - File Generated: keystore";\
	else \
		echo "keystore File already exists for the ENVIRONMENT ${ENVIRONMENT}, use FORCE=true if you want to overwrite"; \
	fi

jenkins_build: generate_keystore## Build the Jenkins Docker
	@cp ./environments/${ENVIRONMENT}/certs/keystore ./docker/Jenkins
	@cp ./templates/${ENVIRONMENT}-plugins.txt ./docker/Jenkins/plugins.txt
	cd ./docker/Jenkins && \
	make build
	@rm ./docker/Jenkins/plugins.txt ./docker/Jenkins/keystore

jenkins_run: ## Run the Jenkins Docker
	cd ./docker/Jenkins && \
	make run

jenkins_push: ## Push the Jenkins Docker to the registry
	cd ./docker/Jenkins && \
	make push

jenkins_pull: ## Pull the Jenkins Docker from the registry
	cd ./docker/Jenkins && \
	make pull

jenkins_bash: ## Bash into Jenkins Docker
	cd ./docker/Jenkins && \
	make bash

jenkins_update: jenkins_build jenkins_push ## Update and push the Jenkins Docker to the registry

exporter_build: # Build Jenkins Exporter Image
	cd ./docker/jenkins_exporter && \
	make build

exporter_run: # Run the Jenkins Exporter Docker
	cd ./docker/jenkins_exporter && \
	make run

exporter_push: # Push the Jenkins Exporter Docker to the registry
	cd ./docker/jenkins_exporter && \
	make push

exporter_pull: # Pull the Jenkins Exporter Docker from the registry
	cd ./docker/jenkins_exporter && \
	make pull

exporter_bash: # Bash into Jenkins Exporter Docker
	cd ./docker/jenkins_exporter && \
	make bash

exporter_update: exporter_build exporter_push # Update and push the Jenkins Exporter Docker to the registry

# Check http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Print this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
