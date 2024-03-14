# Copyright (c) 2024, Nimbix, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are
# those of the authors and should not be interpreted as representing official
# policies, either expressed or implied, of Nimbix, Inc.

# Serial Number
ARG SERIAL_NUMBER=20240314.1000

# Load updated JARVICE MPI with UCX
FROM us-docker.pkg.dev/jarvice/images/mpi-test:custom-mpi-ucx as JARVICE_MPI
FROM rockylinux:9

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER=${SERIAL_NUMBER}

# Grab jarvice_mpi from JARVICE_UCX_MPI
COPY --from=JARVICE_MPI /opt/JARVICE_UCX /opt/JARVICE_UCX

# Install pre-requisite
RUN dnf install -y epel-release && \
    dnf groupinstall -y "Development Tools" && \
    dnf config-manager --set-enabled crb && \
    dnf install -y \
        bzip2\
        htop\
        libpciaccess\
        libyaml-devel\
        papi-devel\
        python3-devel\
        unzip\
        which\
        zip

# Install Jarvice Desktop
RUN curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/jarvice-desktop/master/install-nimbix.sh \
        | bash

RUN ln -s /usr/share/terminfo /lib/terminfo

WORKDIR /tmp
COPY converge.tar.bz2 converge.tar.bz2
RUN tar xjf converge.tar.bz2 -C /opt

COPY TAR TAR
ADD ./install_tools.sh install_tools.sh
RUN	/tmp/install_tools.sh

COPY scripts /usr/local/scripts

ENV PATH=/opt/JARVICE_UCX/openmpi/bin:/opt/JARVICE_UCX/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/opt/JARVICE_UCX/openmpi/lib:/opt/JARVICE_UCX/lib

COPY ./AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate
RUN mkdir -p /etc/NAE && touch /etc/NAE/screenshot.png /etc/NAE/screenshot.txt /etc/NAE/license.txt /etc/NAE/AppDef.json
