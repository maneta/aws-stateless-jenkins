{% if CREATE_VPC == 'true' -%}
module "vpc" {
  source = "github.com/terraform-community-modules/tf_aws_vpc"
  name = "jenkins-{{ JENKINS_NAME }}"
  cidr = "{{ VPC_CIDR_RANGE }}"
  public_subnets = {{ PUBLIC_SUBNETS_RANGE | safe }}
  enable_dns_hostnames = "true"
  enable_dns_support = "true"
  azs = {{ AZS | safe }}
}
{% endif %}
