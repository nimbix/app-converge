#!/usr/bin/env bash
yum -y groupinstall "Development Tools"
yum -y install unzip 
yum -y install libyaml libyaml-devel python3 papi papi-devel
yum -y install iperf htop 
yum -y install texlive-collection-latexrecommended texlive-epstopdf
yum -y install gnuplot-latex
tar xvfz /tmp/TAR/inxi.tar.gz -C /opt
cd /tmp
unzip /tmp/TAR/darshan.zip 
cd darshan-main
./prepare.sh 
./configure --with-mem-align=8 --with-log-path-by-env=/data/var --with-jobid-env=NONE CC=mpicc --prefix=/opt/darshan
make -j 2
make install
sleep 10
cd ..
tar xvfz /tmp/TAR/selfie-1.0.4.tar.gz
cd selfie-1.0.4
./autogen.sh 
./configure --with-mpi --with-papi --with-omp --with-posixio --prefix=/opt/selfie
make -j 2
make install
cd ..
tar zxvf TAR/NPB3.3.1.tar.gz -C /opt
cd /opt/NPB3.3.1/NPB3.3-MPI
cp config/make.def.template config/make.def

cd /opt 
chmod -R a+rwx /opt/selfie 
chmod -R a+rwx /opt/darshan
chmod -R a+rwx /opt/NPB3.3.1
chmod -R a+rwx /opt/inxi-3.3.31-2

