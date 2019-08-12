###################
# Shell detection #
###################

#Detecting OS for base64 command
UNAME := $(shell uname)

#Detecting System Version
ifeq (${UNAME}, Linux)
  BASE64=base64 -w 0
else ifeq (${UNAME}, Darwin)
  BASE64=base64
endif
