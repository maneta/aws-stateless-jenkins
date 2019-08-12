{# ####################### -#}
{# Default variable values -#}
{# ####################### -#}
{% set TOP_DOMAIN                    = R53_PARENT_ZONE_DOMAIN_NAME | default('3sca.net') -%}
{% set REGION                        = REGION -%}
{% set BUCKET_JENKINS_REGION         = BUCKET_JENKINS_REGION -%}
{% set PROMETHEUS_METRICS_ENABLED    = PROMETHEUS_METRICS_ENABLED |  default('true') -%}
{% set ADMIN_IPS                     = ADMIN_IPS | default('["2.139.235.79/32", "54.235.71.22/32", "35.180.149.119/32"]') -%}
{% set ATOMIC_IMAGES                 = ATOMIC_IMAGES | default('{"us-east-1":"ami-956fe882","us-west-2":"ami-17569677","eu-west-1":"ami-a06601d3","eu-central-1":"ami-dca270b3"}') -%}
{% set AZS                           = AZS | default ('["' ~ REGION ~ 'a", "' ~ REGION ~ 'b", "' ~ REGION ~ 'c"]') -%}
{% set JENKINS_NAME                  = JENKINS_NAME -%}
{% set DNS_DOMAIN                    = DNS_ZONE | default( JENKINS_NAME ~ '.' ~ TOP_DOMAIN ) %}
{% set DOCKER_AUTH_TOKEN             = DOCKER_AUTH_TOKEN -%}
{% set DNS_PARENT_ZONE_ID            = R53_PARENT_ZONE_ID %}
{% set EC2_SSH_KEY_NAME              = EC2_SSH_KEY_NAME | default('3scale2014') -%}
{% set VPC_CIDR_RANGE                = VPC_CIDR_RANGE | default('10.0.0.0/16') -%}
{% set PUBLIC_SUBNETS_RANGE          = PUBLIC_SUBNETS_RANGE | default('["10.0.1.0/24", "10.0.2.0/24"]') -%}
{% set DOWNLOAD_BUCKET               = DOWNLOAD_BUCKET | default( JENKINS_NAME ~ 'jenkins-environment' ) -%}
{% set NODE_EXPORTER_DOCKER_IMAGE    = NODE_EXPORTER_DOCKER_IMAGE | default('quay.io/prometheus/node-exporter:v0.14.0') -%}
{% set JENKINS_USER                  = JENKINS_USER -%}
{% set JENKINS_TOKEN                 = JENKINS_TOKEN -%}
{% set JENKINS_HOSTNAME              = JENKINS_HOSTNAME -%}
{% set ENABLE_SLAVE_NODES            = ENABLE_SLAVE_NODES | default('true') -%}
{% set JENKINS_EXPORTER_DOCKER_IMAGE = JENKINS_EXPORTER_DOCKER_IMAGE | default('quay.io/3scale/jenkins-exporter:1706261756') -%}
{% set SLAVES_VPC_REGION_DATA        = SLAVES_VPC_REGION_DATA  | default('[]') %}

{# VPC vars #}
{% set CREATE_VPC     = CREATE_VPC | default('false') -%}
{% set SUBNETS_ATTACH = SUBNETS_ATTACH -%}
{% set VPC_ATTACH     = VPC_ATTACH -%}

{% if CREATE_VPC == 'true' -%}
  # VPC
  {% include "vpc.tpl" %}
  {% set VPC_REF               = '${module.vpc.vpc_id}' -%}
  {% set SUBNETS_REF           = '["${module.vpc.public_subnets}"]' -%}
  {% set SEPARATED_SUBNETS_REF = '["${element(module.vpc.public_subnets,0)}","${element(module.vpc.public_subnets,1)}"]' -%}
{% else -%}
  {% set VPC_REF               = VPC_ATTACH -%}
  {% set SUBNETS_REF           = SUBNETS_ATTACH -%}
  {% set SEPARATED_SUBNETS_REF = SUBNETS_ATTACH -%}
{% endif -%}

#S3 Backend
{% include "source_state.tpl" %}

# Providers
{% include "providers.tpl" %}

{% if ENABLE_SLAVE_NODES == "true" -%}
  # Slave Nodes
  {% include "nodes.tpl" %}
  {% include "slaves.tpl" %}
{% endif -%}

# EFS Jenkins
{% include "efs.tpl" %}

# DNSs
{% set R53_ADD_NS_TO_PARENT_ZONE = R53_ADD_NS_TO_PARENT_ZONE | default('false') -%}

{% if R53_ADD_NS_TO_PARENT_ZONE == "true" -%}
  ## External
  {% set R53_ZONE_NAME      = JENKINS_NAME -%}
  {% set R53_ZONE_DOMAIN    = DNS_DOMAIN -%}
  {% set R53_PARENT_ZONE_ID = DNS_PARENT_ZONE_ID -%}
  {% set R53_VPC_ID         = VPC_REF -%}
  {% set R53_VPC_REGION     = REGION -%}
  {% include "dns_zone.tpl" %}
{% endif -%}

# Jenkins Master
{% set JENKINS_ROOT_SIZE                    = JENKINS_ROOT_SIZE | default('40') -%}
{% set JENKINS_MASTER_DATA_DISK_DEV_ATTACH  = JENKINS_MASTER_DATA_DISK_DEV_ATTACH | default('/dev/xvdi') -%}
{% set JENKINS_MASTER_DATA_FS_SIZE          = JENKINS_MASTER_DATA_FS_SIZE | default('100') -%}
{% set JENKINS_MASTER_INSTANCE_TYPE         = JENKINS_MASTER_INSTANCE_TYPE %}
{% set JENKINS_DNS                          = JENKINS_DNS | default('jenkins-aws.' ~ DNS_DOMAIN ) -%}
{% include "jenkins-master.tpl" %}
