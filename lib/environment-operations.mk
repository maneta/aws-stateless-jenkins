##########################
# Environment Operations #
##########################


list-environments: ## List all the OS Environments in S3.
	@aws s3 ls | grep ${S3_BUCKET_SUFFIX}

#Sets default region for env bucket if not set
ENV_AWS_REGION ?= "us-east-1"
create_bucket: # Create S3 Bucket for the Cluster´s Configuration Files
	@echo "[INFO] - Creating S3 Bucket"
	@if aws s3 ls | grep ${ENVIRONMENT}-${S3_BUCKET_SUFFIX} >/dev/null ; then \
			echo "s3://${ENVIRONMENT}-${S3_BUCKET_SUFFIX} already exists" ; \
			if [ ${FORCE} != "true" ]; then \
				exit 1; \
			fi \
		else \
			aws s3 mb s3://${ENVIRONMENT}-${S3_BUCKET_SUFFIX} --region ${ENV_AWS_REGION} ; \
			aws s3api put-bucket-versioning --bucket ${ENVIRONMENT}-${S3_BUCKET_SUFFIX} --versioning-configuration Status=Enabled ;\
		fi

create_environment_dir: # Creates the local environment dir
	@echo "[INFO] - Creating local environment dir: ./environments/${ENVIRONMENT}"
	@if [ ! -d "./environments/${ENVIRONMENT}" ] || [ ${FORCE} == "true" ] ; then \
		mkdir -p ./environments/${ENVIRONMENT} ; \
	else \
		echo "Local dir already exists, use FORCE=true if you want to overwrite";\
		exit 1;\
	fi

pull: create_environment_dir ## Pulls an environment from S3
	@if [ -z "$(ls -A ./environments/${ENVIRONMENT}/)" ] || [ ${FORCE} == "true" ]; then\
		aws s3 cp s3://${ENVIRONMENT}-${S3_BUCKET_SUFFIX}/ ./environments/${ENVIRONMENT}/ --recursive --exclude="*.state" --exclude "registry/*";\
	else \
		echo "./environments/${ENVIRONMENT}/ has files, use FORCE=true";\
		exit 1;\
	fi

push: ## Pushes local environment to S3
	@if [ "$$(aws s3 ls s3://${ENVIRONMENT}-${S3_BUCKET_SUFFIX}/| wc -l| awk '{$$1=$$1;print}')" == "0" ] || [ ${FORCE} == "true" ]; then\
		aws s3 cp ./environments/${ENVIRONMENT}/ s3://${ENVIRONMENT}-${S3_BUCKET_SUFFIX}/ --recursive  --exclude="*.state" --exclude='.terraform/*';\
	else \
		echo "s3://${ENVIRONMENT}-${S3_BUCKET_SUFFIX} has files, use FORCE=true";\
		exit 1;\
	fi

clean_local:
	@rm -rf "./environments/${ENVIRONMENT}/"
