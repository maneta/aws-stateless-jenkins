{% for SLAVE in SLAVES_VPC_REGION_DATA | from_json %}
resource "aws_security_group" "slaves-sg-{{ SLAVE.region }}" {
{% if SLAVE.region != REGION %}
  provider       = "aws.{{ SLAVE.region }}"
{% endif  %}
  name        = "{{ JENKINS_NAME }}-slaves-sg-{{ SLAVE.region }}"
  description = "Slave Security Group"
  vpc_id      = "{{ SLAVE.vpc }}"

  tags {
    Name         = "{{ JENKINS_NAME }}-slaves-sg-{{ SLAVE.region }}"
    stack        = "jenkins"
    jenkins_name = "{{ JENKINS_NAME }}"
    layer        = "slaves"
  }
}

resource "aws_security_group_rule" "slavess-sg-egress-{{ SLAVE.region }}" {
{% if SLAVE.region != REGION %}
  provider       = "aws.{{ SLAVE.region }}"
{% endif  %}
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.slaves-sg-{{ SLAVE.region }}.id}"
}

resource "aws_security_group_rule" "slaves-sg-allow-office-{{ SLAVE.region }}" {
{% if SLAVE.region != REGION %}
  provider       = "aws.{{ SLAVE.region }}"
{% endif  %}
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = {{ ADMIN_IPS | safe }}
  security_group_id = "${aws_security_group.slaves-sg-{{ SLAVE.region }}.id}"
}

resource "aws_security_group_rule" "slaves-sg-allow-master-{{ SLAVE.region }}" {
{% if SLAVE.region != REGION %}
  provider       = "aws.{{ SLAVE.region }}"
{% endif  %}
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  cidr_blocks = ["${aws_eip.jenkins-master.public_ip}/32"]
  security_group_id        = "${aws_security_group.slaves-sg-{{ SLAVE.region }}.id}"
}
resource "aws_security_group_rule" "slaves-sg-allow-itself-{{ SLAVE.region }}" {
{% if SLAVE.region != REGION %}
  provider       = "aws.{{ SLAVE.region }}"
{% endif  %}
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  source_security_group_id = "${aws_security_group.slaves-sg-{{ SLAVE.region }}.id}"
  security_group_id        = "${aws_security_group.slaves-sg-{{ SLAVE.region }}.id}"
}
{% endfor %}
