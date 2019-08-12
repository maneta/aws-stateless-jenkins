####################
# Variables export #
####################

#Check if the configuration file already exists
ifneq ("$(wildcard ./environments/${ENVIRONMENT}/config.mk)","")
   include ./environments/${ENVIRONMENT}/config.mk
   export $(shell sed 's/=.*//' ./environments/${ENVIRONMENT}/config.mk)
else ifneq ("$(MAKECMDGOALS)","help")
    $(info Configuration for the ENVIRONMENT ${ENVIRONMENT} not found )
endif
