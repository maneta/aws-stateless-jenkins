########################
# Terraform Operations #
########################

TERRAFORM_COMMAND = docker run -u `id -u` -i -t -v $$(pwd):/app/ -w /app/ \
                    -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
                    -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
                    hashicorp/terraform:${TERRAFORM_VERSION}

terraform_generate_environment: ## Initialize Terraform Project.
	@echo "[INFO] - Iniatializing Terraform Project"
	@if [ ! -f ./environments/${ENVIRONMENT}/all.tf ] || [ ${FORCE} == "true" ]; then\
		envtpl ./terraform-jinja/all.tpl -o ./environments/${ENVIRONMENT}/all.tf --allow-missing --keep-template; \
	else \
		echo " Terraform environment already exists, use FORCE=true";\
		exit 1;\
	fi

terraform_generate_backend_config:
	@echo "[INFO] - Iniatializing Terraform Project"
	@if [ ! -f ./environments/${ENVIRONMENT}/terraform-backend-config ] || [ ${FORCE} == "true" ]; then\
		envtpl --keep-template ./templates/terraform-backend-config.tpl -o ./environments/${ENVIRONMENT}/terraform-backend-config;\
	else \
		echo "terraform-backend-config already exists, use FORCE=true";\
		exit 1;\
	fi

terraform_initialize: ## Configures the terraform environment and backend.
	@echo "[INFO] - Terraform Configuration"
	@rm -rf ./environments/${ENVIRONMENT}/.terraform/
	@cd ./environments/${ENVIRONMENT}/ \
	&& $(TERRAFORM_COMMAND) \
	init -get=true -backend=true -backend-config=terraform-backend-config
	@echo "[OK] - Terraform Configured"

terraform_plan: terraform_initialize ## Plan(Dry Run) the Terraform Project.
	@echo "[INFO] - Planning the Terraform Deployment"
	@cd ./environments/${ENVIRONMENT}/ \
	&& $(TERRAFORM_COMMAND) \
	plan
	@echo "[OK] - Terraform Planning Done"

terraform_apply: terraform_initialize ## Apply(Deploy) the Terraform Project on AWS.
	@echo "[INFO] - Deploying Terraform Infrastucture in AWS"
	@cd ./environments/${ENVIRONMENT}/ \
	&& $(TERRAFORM_COMMAND) \
	apply
	@echo "[OK] - Terraform Deploy Done"

terraform_destroy: terraform_initialize ## Destroy all the CLUSTER Resources in AWS.
	@echo "[INFO] - Destroying AWS Infrastructure"
	@cd ./environments/${ENVIRONMENT}/  \
	&& $(TERRAFORM_COMMAND) \
	destroy
	@echo "[OK] - AWS Infrastructure Destroyed"

terraform_output: ## Print all the Terraform Project Outputs.
	@cd ./environments/${ENVIRONMENT}/ \
	&& $(TERRAFORM_COMMAND) \
	output ${OUTPUT}
