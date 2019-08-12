provider "aws" {
  region     = "{{ REGION }}"
}

{% for SLAVE in SLAVES_VPC_REGION_DATA | from_json %}
{% if SLAVE.region != REGION %}
provider "aws" {
  alias      = "{{ SLAVE.region }}"
  region     = "{{ SLAVE.region }}"
}
{% endif  %}
{% endfor %}
