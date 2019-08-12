resource "aws_instance" "jenkins-master" {
  ami                         = "{{ (ATOMIC_IMAGES | from_json)[REGION] }}"
  instance_type               = "{{ JENKINS_MASTER_INSTANCE_TYPE }}"
  key_name                    = "{{ EC2_SSH_KEY_NAME }}"
  vpc_security_group_ids      = ["${aws_security_group.jenkins-master.id}"]
  associate_public_ip_address = true

  tags {
    Name         = "jenkins-{{ JENKINS_NAME }}-master"
    stack        = "jenkins"
    cluster_name = "{{ JENKINS_NAME }}"
    layer        = "master"
    monitoring   = "true"
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = "{{ JENKINS_ROOT_SIZE }}"
  }

  ebs_block_device {
    device_name           = "{{ JENKINS_MASTER_DATA_DISK_DEV_ATTACH }}"
    volume_size           = "{{ JENKINS_MASTER_DATA_FS_SIZE }}"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data         = <<EOF
{% include "user-data/jenkins_master_node.tpl" %}
EOF
  availability_zone = "{{ ( AZS | from_json )[0] }}"
  subnet_id         = "{{ (SEPARATED_SUBNETS_REF | from_json)[0] }}"
}

resource "aws_eip" "jenkins-master" {
  instance = "${aws_instance.jenkins-master.id}"
  vpc      = true
}

resource "aws_security_group" "jenkins-master" {
  name        = "jenkins-{{ JENKINS_NAME }}-master"
  description = "SG for Jenkins Master"
  vpc_id      = "{{ VPC_REF }}"

  tags {
    stack        = "jenkins"
    cluster_name = "{{ JENKINS_NAME }}"
    layer        = "master"
  }
}

resource "aws_security_group_rule" "jenkins-master-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins-master.id}"
}

resource "aws_security_group_rule" "jenkins-master-allow-office" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = {{ ADMIN_IPS }}
  security_group_id = "${aws_security_group.jenkins-master.id}"
}

resource "aws_security_group_rule" "jenkins-master-allow-https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = "${aws_security_group.jenkins-master.id}"
}

resource "aws_security_group_rule" "efs-allow-jenkins-master" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.jenkins-master.id}"
  security_group_id        = "${aws_security_group.jenkins-efs.id}"
}

resource "aws_security_group_rule" "allow-node-exporter" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  cidr_blocks              = ["34.225.25.136/32"]
  security_group_id        = "${aws_security_group.jenkins-master.id}"
}

resource "aws_security_group_rule" "allow-jenkins-exporter" {
  type                     = "ingress"
  from_port                = 9118
  to_port                  = 9118
  protocol                 = "tcp"
  cidr_blocks              = ["34.225.25.136/32"]
  security_group_id        = "${aws_security_group.jenkins-master.id}"
}

resource "aws_route53_record" "jenkins-master" {
  {% if R53_ADD_NS_TO_PARENT_ZONE == "true" -%}
    zone_id = "${aws_route53_zone.{{ JENKINS_NAME }}.zone_id}"
  {% else -%}
    zone_id = "{{ R53_PARENT_ZONE_ID }}"
  {% endif -%}
  name    = "{{ JENKINS_DNS }}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_instance.jenkins-master.public_dns}"]
}
