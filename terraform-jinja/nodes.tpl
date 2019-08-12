  resource "aws_security_group" "nodes-sg" {
  name        = "{{ JENKINS_NAME }}-nodes-sg"
  description = "Slave Nodes Security Group"
  vpc_id      = "{{ VPC_REF }}"

  tags {
    Name         = "{{ JENKINS_NAME }}-nodes-sg"
    stack        = "jenkins"
    jenkins_name = "{{ JENKINS_NAME }}"
    layer        = "nodes"
  }
}

resource "aws_security_group_rule" "nodes-sg-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nodes-sg.id}"
}

resource "aws_security_group_rule" "nodes-sg-allow-office" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = {{ ADMIN_IPS | safe }}
  security_group_id = "${aws_security_group.nodes-sg.id}"
}

resource "aws_security_group_rule" "nodes-sg-allow-master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  source_security_group_id = "${aws_security_group.jenkins-master.id}"
  security_group_id        = "${aws_security_group.nodes-sg.id}"
}

resource "aws_security_group_rule" "nodes-sg-allow-michal" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks              = ["86.49.99.52/32"]
  security_group_id        = "${aws_security_group.nodes-sg.id}"
}
