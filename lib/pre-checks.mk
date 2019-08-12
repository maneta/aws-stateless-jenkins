##############
# Pre checks #
##############

#It prints the help usage or brake in case of there is no environmente set.
ifeq ("$(MAKECMDGOALS)","")
   $(info Makefile usage Help:)
else ifeq ("$(MAKECMDGOALS)","help")
   $(info Makefile usage Help:)
else ifeq ("$(MAKECMDGOALS)","list-environments")
   $(info OS Environments in S3:)
else ifeq (${ENVIRONMENT},"")
    $(error "ENVIRONMENT" var not set.)
endif
