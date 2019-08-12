FROM jenkins/jenkins:2.138.3
LABEL authors="Daniel Cesario <dcesario@redhat.com>"

USER root

RUN rm -rf /usr/share/jenkins/ref/* && \
    apt-get update && apt-get install -y \
    libcap2-bin && \
    rm -rf /var/lib/apt/lists/*

USER 1000

ARG GITHUB_TOKEN
ARG GITHUB_JENKINS_REPO

COPY keystore /var/lib/jenkins/keystore
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

ENV JENKINS_OPTS --httpPort=-1 --httpsPort=443 --httpsKeyStore=/var/lib/jenkins/keystore --httpsKeyStorePassword=jenkins

RUN rm -rf /tmp/sync* && \
    git clone https://${GITHUB_TOKEN}@${GITHUB_JENKINS_REPO} /tmp/sync-jenkins && \
    cp -R /tmp/sync-jenkins/* /usr/share/jenkins/ref/ && \
    cp  /tmp/sync-jenkins/.gitconfig /usr/share/jenkins/ref/ && \
    rm -rf /usr/share/jenkins/ref/.git && \
    rm -rf /tmp/sync-jenkis

USER root
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt
RUN setcap 'cap_net_bind_service=+ep' /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

USER 1000
EXPOSE 443
