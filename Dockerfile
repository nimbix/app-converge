# Official image
FROM centos:7

##############################
### Configure Repositories ###
##############################

COPY ./repos_ifpen /etc/yum.repos.d
COPY ./rpm-gpg /etc/pki/rpm-gpg

#######################
### Update packages ###
#######################

RUN yum clean all

RUN yum update -y && \
    yum clean all

###########################################
### Install a recent version of libpsm2 ###
###########################################

COPY ./rpms/libpsm2-11.2.204-1.x86_64.rpm /tmp
COPY ./rpms/libpsm2-devel-11.2.204-1.x86_64.rpm /tmp
RUN yum install -y \
      /tmp/libpsm2-11.2.204-1.x86_64.rpm \
      /tmp/libpsm2-devel-11.2.204-1.x86_64.rpm && \
    yum clean all

#########################################
### Jarvice : Install jarvice-desktop ###
#########################################

ENV JARVICE_DESKTOP_ITER 1

#RUN yum install -y ca-certificates && \
#    curl -H 'Cache-Control: no-cache' \
#        https://raw.githubusercontent.com/nimbix/jarvice-desktop/master/install-nimbix.sh \
#        | bash

COPY ./install-nimbix.sh /tmp/install-nimbix.sh

ADD ./install_tools.sh /tmp/install_tools.sh
ADD ./TAR /tmp/TAR

RUN yum install -y ca-certificates && \
    bash /tmp/install-nimbix.sh && \
    rm -f /tmp/install-nimbix.sh && \
	bash /tmp/install_tools.sh
	

##############################
### Web shell : workaround ###
##############################

# Fix 'INIT[36]: Starting web-based shell as user nimbix...FATAL: main(): terminfo: Permission denied' on el images
RUN ln -s /usr/share/terminfo /lib/terminfo

###############################
### Jarvice: install AppDef ###
###############################

# Reference: https://github.com/nimbix/app-pythondev/tree/master

COPY ./AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate
RUN mkdir -p /etc/NAE && touch /etc/NAE/screenshot.png /etc/NAE/screenshot.txt /etc/NAE/license.txt /etc/NAE/AppDef.json

#######################
### Job environment ###
#######################

COPY --chown=root:root ./job-env.sh /etc/profile.d/job-env.sh

############################
### Converge environment ###
############################

ENV PATH=/opt/converge/bin:/opt/openmpi/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin
ENV LD_LIBRARY_PATH=/opt/converge/lib:/opt/openmpi/lib
ENV OPAL_PREFIX=/opt/openmpi
ENV PMIX_PREFIX=/opt/openmpi
ENV PRTE_PREFIX=/opt/openmpi
ENV RLM_LICENSE=2765@l40324.lic.nimbix.net

###############################################
### Copy Converge binaries and dependencies ###
###############################################

ADD --chown=root:root ./build/converge.tar.xz /
