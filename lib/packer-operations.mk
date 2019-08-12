#####################
# Packer Operations #
#####################

PACKER_COMMAND = docker run -u `id -u` --rm -i -t -v $$(pwd):/app/ -w /app/ \
                    -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
                    -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
                    hashicorp/packer:${PACKER_VERSION}

check-region: # Check REGION VAR
	@if [ ! ${REGION} ] ; then \
                echo "[ERROR] REGION VAR NOT SET!!!" ; \
                echo "-------------------------------------" ; \
                echo "Showing help:" ; \
                make help --no-print-directory ; \
                exit -1; \
        else \
                echo "[INFO] - REGION: ${REGION}" ; \
        fi

packer_validate: check-region ## Validate Packer template
	@echo "[INFO] - Validate Packer template"
	@$(PACKER_COMMAND) validate -var-file=templates/${REGION}.json template.json
	@echo "[OK] - Validate Packer template Done"

packer_inspect: packer_validate ## Inspect Packer template
	@echo "[INFO] - Inspect Packer template"
	@$(PACKER_COMMAND) inspect template.json
	@echo "[OK] - Inspect Packer template Done"

packer_build: packer_validate ## Build AMI
	@echo "[INFO] - Building AMI"
	@$(PACKER_COMMAND) build -var-file=templates/${REGION}.json template.json
	@echo "[OK] - Packer Build AMI Done"

packer_debug: packer_validate ## Build AMI with Debug enabled
	@echo "[INFO] - Debugging AMI"
	@$(PACKER_COMMAND) build -debug -var-file=templates/${REGION}.json template.json
	@echo "[OK] - Packer Debug AMI Done"
