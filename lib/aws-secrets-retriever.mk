########################
# AWS Secrets Retriever #
########################

AWS_SECRET_RETRIEVER_COMMAND = docker run --rm -it -u 10000001 \
                               -e AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID \
                               quay.io/3scale/aws-secret-retriever:${AWS_SECRET_RETRIEVER_VERSION}
