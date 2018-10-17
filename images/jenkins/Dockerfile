FROM jenkins/jenkins:lts-alpine

##############################################################################################################################
############## Install tools
USER root

# set variables
ARG jenkins_ref="/usr/share/jenkins/ref"
ARG docker_compose_version="1.22.0"
ARG packer_version="1.3.1"
ARG terraform_version="0.11.8"
ARG timezone="America/Toronto"

ENV JENKINS_REF $jenkins_ref
ENV DOCKER_COMPOSE_VERSION $docker_compose_version
ENV PACKER_VERSION $packer_version
ENV TERRAFORM_VERSION $terraform_version
ENV TIMEZONE $timezone

# update and install common packages
RUN set +x \
  && env \
  && apk update \
  && apk upgrade \
  && apk add openrc openntpd tzdata python3 jq git \
  && pip3 install --upgrade pip setuptools \
  && apk add sudo

# install Docker Compose
RUN set +x \
  && curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m`" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

# install AWS CLI
RUN set +x \
  && pip3 install awscli --upgrade \
  && exec bash

# set timezone to America/Toronto
RUN set +x \
  && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
  && echo ${TIMEZONE}  >  /etc/timezone \
  && date

RUN apk -U add docker
# Setup Jenkins
RUN apk add --update shadow \
    && groupadd -g 50 staff \
    && usermod -a -G staff,docker jenkins

RUN chown -R jenkins:staff /var/jenkins_home
RUN rc-update add docker boot

################ Configure Jenkins

USER jenkins
ENV JENKINS_REF /usr/share/jenkins/ref

# install jenkins plugins
COPY resources/plugins.txt $JENKINS_REF/
RUN /usr/local/bin/install-plugins.sh $(cat $JENKINS_REF/plugins.txt | tr '\n' ' ')

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# copy scripts and ressource files
COPY resources/init.groovy.d $JENKINS_REF/init.groovy.d/
COPY resources/dsl $JENKINS_REF/dsl/

#COPY https.pem /var/lib/jenkins/cert
#COPY https.key /var/lib/jenkins/pk
#ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8083 --httpsCertificate=/var/lib/jenkins/cert --httpsPrivateKey=/var/lib/jenkins/pk
#EXPOSE 8083
