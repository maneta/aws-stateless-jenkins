resource "aws_route53_zone" "{{ R53_ZONE_NAME }}" {
  name = "{{ R53_ZONE_DOMAIN }}"
  {% if R53_VPC_ID != "" and R53_VPC_ID is defined and R53_VPC_REGION != "" and R53_VPC_REGION is defined -%}
    vpc {
       vpc_id = "{{ R53_VPC_ID }}"
       vpc_region = "{{ R53_VPC_REGION }}"
    }
  {% elif R53_VPC_ID != "" and R53_VPC_ID is defined-%}
     vpc {
       vpc_id = "{{ R53_VPC_ID }}"
    }
  {% elif R53_VPC_REGION != "" and R53_VPC_REGION is defined -%}
    vpc {
       vpc_region = "{{ R53_VPC_REGION }}"
    }
  {% endif -%}
  tags = {
    stack        = "jenkins"
    cluster_name = "{{ JENKINS_NAME }}"
    layer        = "dns"
  }
}

{% if R53_ADD_NS_TO_PARENT_ZONE == "true" -%}
resource "aws_route53_record" "{{ R53_ZONE_NAME }}-ns" {
    zone_id = "{{ R53_PARENT_ZONE_ID }}"
    name = "{{ R53_ZONE_DOMAIN }}"
    type = "NS"
    ttl = "30"
    records = [
        "${aws_route53_zone.{{ R53_ZONE_NAME }}.name_servers.0}",
        "${aws_route53_zone.{{ R53_ZONE_NAME }}.name_servers.1}",
        "${aws_route53_zone.{{ R53_ZONE_NAME }}.name_servers.2}",
        "${aws_route53_zone.{{ R53_ZONE_NAME }}.name_servers.3}"
    ]
}
{% endif -%}
