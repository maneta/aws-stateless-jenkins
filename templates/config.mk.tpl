###################
# Global Settings #
##################
JENKINS_NAME                  = {{ ENVIRONMENT | default('') }}
BUCKET_JENKINS_REGION         = {{ BUCKET_JENKINS_REGION | default('us-east-1') }}
REGION                        = {{ REGION | default('') }}
JENKINS_USER                  = {{ JENKINS_USER | default('@@Change_Me@@') }}
JENKINS_TOKEN                 = {{ JENKINS_TOKEN | default('@@Change_Me@@') }}
JENKINS_HOSTNAME              = {{ JENKINS_HOSTNAME | default('@@Change_Me@@') }}
{% set S3_BUCKET_SUFFIX       = S3_BUCKET_SUFFIX | default('jenkins-environment') -%}
S3_JENKINS_BUCKET             = {{ ENVIRONMENT }}-{{ S3_BUCKET_SUFFIX }}
AZS                           = ["{{ REGION }}a", "{{ REGION }}b"]
R53_PARENT_ZONE_ID            = {{ R53_PARENT_ZONE_ID | default('Z1JZPW1FMMXUCP') }}
R53_PARENT_ZONE_DOMAIN_NAME   = {{ R53_PARENT_ZONE_DOMAIN_NAME }}
R53_ADD_NS_TO_PARENT_ZONE     = {{ R53_ADD_NS_TO_PARENT_ZONE | default('true') }}
CREATE_VPC                    = {{ CREATE_VPC | default('false') }}
VPC_ATTACH                    = {{ VPC_ATTACH | default("") }}
SUBNETS_ATTACH                = {{ SUBNETS_ATTACH | default('["subnet-12345","subnet-12346","subnet-12347"]') }}
ATOMIC_IMAGES                 = {{ ATOMIC_IMAGES | default('{"us-east-1":"ami-a50d85b3","us-west-2":"ami-42233726","eu-west-1":"ami-49063c2f","eu-central-1":"ami-dca270b3"') }}
DOCKER_USER                   = {{ DOCKER_USER | default('3scale+openshift') }}
DOCKER_PASSWORD               = {{ DOCKER_PASSWORD | default('@@Change_Me@@') }}
DOCKER_AUTH_TOKEN             = {{ DOCKER_AUTH_TOKEN }}
JENKINS_MASTER_INSTANCE_TYPE  = {{ JENKINS_MASTER_INSTANCE_TYPE | default('@@Change_Me@@') }}
JENKINS_IMAGE_VERSION         = {{ JENKINS_IMAGE_VERSION | default('2.46.1-1704241147') }}
SLAVE_NODES_AMI_ID            = {{ SLAVE_NODES_AMI_ID | default('ami-01d30f6e') }}
GITHUB_TOKEN                  = {{ GITHUB_TOKEN | default('@@Change_Me@@') }}
GITHUB_JENKINS_REPO           = {{ GITHUB_JENKINS_REPO | default('github.com/3scale/change-me.git')}}
ENABLE_SLAVE_NODES            = {{ ENABLE_SLAVE_NODES | default('true') }}
SLAVES_VPC_REGION_DATA        = {{ SLAVES_VPC_REGION_DATA | default('[{"region":"","vpc":""},{"region":"","vpc":""}]') }}
