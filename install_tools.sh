#!/bin/bash
yum -y groupinstall "Development Tools"
yum -y install unzip
tar xvfz /tmp/TAR/inxi.tar.gz -C /opt
cd /tmp
unzip /tmp/TAR/darshan.zip 
cd darshan-main
./prepare.sh 
./configure --prefix=/opt/darshan 
make -j 2
make install
sleep 10
cd ..
tar xvfz /tmp/TAR/selfie-1.0.4.tar.gz
cd selfie-1.0.4
./autogen.sh 
./configure



