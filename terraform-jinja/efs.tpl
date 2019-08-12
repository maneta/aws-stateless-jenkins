resource "aws_efs_file_system" "jenkins-volumes" {
  creation_token = "{{ JENKINS_NAME }}-volumes"

  tags {
    Name         = "{{ JENKINS_NAME }}-volumes"
    stack        = "jenkins"
    cluster_name = "{{ JENKINS_NAME }}"
    layer        = "jenkins-storage"
  }
}

{% for MOUNT_ID in range(0, 2) -%}
resource "aws_efs_mount_target" "jenkins-volumes-0{{ MOUNT_ID + 1 }}" {
  file_system_id  = "${aws_efs_file_system.jenkins-volumes.id}"
  subnet_id       = "{{ (SEPARATED_SUBNETS_REF | from_json)[MOUNT_ID] }}"
  security_groups = ["${aws_security_group.jenkins-efs.id}"]
}
{% endfor %}

resource "aws_security_group" "jenkins-efs" {
  name        = "{{ JENKINS_NAME }}-efs"
  description = "Jenkins Elastic FS SG - cluster: {{ JENKINS_NAME }}"
  vpc_id      = "{{ VPC_REF }}"
}

output "efs_id" {
  value = "${aws_efs_file_system.jenkins-volumes.id}"
}
