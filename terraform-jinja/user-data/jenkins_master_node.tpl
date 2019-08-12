#cloud-config
mounts:
    - [ {{ JENKINS_MASTER_DATA_DISK_DEV_ATTACH }}, /mnt/jenkins ]

write_files:
    - path: /root/.docker/config.json
      owner: root:root
      permissions: '0600'
      content: |
        {
          "auths": {
            "quay.io": {
              "auth": "{{ DOCKER_AUTH_TOKEN }}"
            }
          }
        }
    - path: /etc/sysconfig/docker-storage-setup
      owner: root:root
      permissions: '0660'
      content: |
        ROOT_SIZE=20G
        GROWPART=true
        AUTO_EXTEND_POOL=true
    - path: /etc/systemd/journald.conf
      owner: root:root
      permissions: '0660'
      content: |
        SystemMaxFileSize=100M
        SystemMaxUse=5G
        Storage=persistent
    - path: /etc/systemd/system/jenkins.service
      owner: root:root
      permissions: '0660'
      content: |
        [Unit]
        Description=Docker execution of jenkins
        Requires=docker.service
        After=docker.service

        [Service]
        User=root
        Restart=on-failure
        RestartSec=10
        Type=simple
        ExecStartPre=-/usr/bin/docker kill jenkins
        ExecStartPre=-/usr/bin/docker rm jenkins
        ExecStart=/bin/sh -c '/usr/bin/docker run --privileged --name jenkins  -e GIT_COMMITTER_NAME="Jenkins AutoCommit" -e GIT_COMMITTER_EMAIL="jenkins@3scale.com" --net=host -v /mnt/jenkins:/var/jenkins_home  -v /mnt/builds:/var/builds -v /tmp:/var/workspace quay.io/3scale/jenkins:{{ JENKINS_IMAGE_VERSION }}'
        ExecStop=-/usr/bin/docker stop jenkins

        [Install]
        WantedBy=multi-user.target
{% if PROMETHEUS_METRICS_ENABLED == "true" %}
    - path: /etc/systemd/system/node-exporter.service
      owner: root:root
      permissions: '0660'
      content: |
        [Unit]
        Description=Docker execution of node exporter
        Requires=docker.service
        After=docker.service

        [Service]
        User=root
        Restart=on-failure
        RestartSec=10
        Type=simple
        ExecStartPre=-/usr/bin/docker kill node-exporter
        ExecStartPre=-/usr/bin/docker rm node-exporter
        ExecStart=/bin/sh -c '/usr/bin/docker run --net=host -v /proc:/host/proc -v /sys:/host/sys -v /:/rootfs --name node-exporter  {{ NODE_EXPORTER_DOCKER_IMAGE }} -collector.procfs /host/proc -collector.sysfs /host/sys -collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"'
        ExecStop=-/usr/bin/docker stop node-exporter

        [Install]
        WantedBy=multi-user.target

    - path: /etc/systemd/system/jenkins-exporter.service
      owner: root:root
      permissions: '0660'
      content: |
        [Unit]
        Description=Docker execution of Jenkins exporter
        Requires=docker.service
        After=docker.service

        [Service]
        User=root
        Restart=on-failure
        RestartSec=10
        Type=simple
        ExecStartPre=-/usr/bin/docker kill jenkins-exporter
        ExecStartPre=-/usr/bin/docker rm jenkins-exporter
        ExecStart=/bin/sh -c '/usr/bin/docker run --net=host --name jenkins-exporter -e APP_FILE=jenkins_exporter.py -e JENKINS_SERVER=https://{{ JENKINS_HOSTNAME }} -e JENKINS_USER={{ JENKINS_USER }} -e JENKINS_PASSWORD={{ JENKINS_TOKEN }} {{ JENKINS_EXPORTER_DOCKER_IMAGE }}'
        ExecStop=-/usr/bin/docker stop node-exporter

        [Install]
        WantedBy=multi-user.target
{% endif -%}

runcmd:
  - sleep 30
  - systemctl restart systemd-journald
  - blkid {{ JENKINS_MASTER_DATA_DISK_DEV_ATTACH }} | grep -q ext4 || mkfs -t ext4 -L jenkins {{ JENKINS_MASTER_DATA_DISK_DEV_ATTACH }}
  - sleep 30
  - mkdir -p /mnt/builds/
  - echo "${aws_efs_file_system.jenkins-volumes.id}.efs.{{ REGION }}.amazonaws.com:/ /mnt/builds/ nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,x-systemd.automount 0 0" >> /etc/fstab
  - sleep 45
  - mount -a
  - chown 1000 /var/mnt/jenkins/
  - chown 1000 /var/mnt/builds/
  - chcon -Rt svirt_sandbox_file_t /mnt/jenkins/
  - mkdir /etc/systemd/system/docker.service.wants/
  - ln -s /etc/systemd/system/jenkins.service /etc/systemd/system/docker.service.wants/
{% if PROMETHEUS_METRICS_ENABLED == "true" %}
  - ln -s /etc/systemd/system/node-exporter.service /etc/systemd/system/docker.service.wants/
  - ln -s /etc/systemd/system/jenkins-exporter.service /etc/systemd/system/docker.service.wants/
{% endif %}
  - systemctl daemon-reload
  - sleep 10
  - systemctl restart --no-block docker
