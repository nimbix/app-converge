#!/usr/bin/env bash

export PATH=/opt/JARVICE_UCX/openmpi/bin:$PATH
export LD_LIBRARY_PATH=/opt/JARVICE_UCX/lib

tar xvfz /tmp/TAR/inxi.tar.gz -C /opt
cd /tmp
unzip /tmp/TAR/darshan.zip
cd darshan-main
./prepare.sh
./configure --with-mem-align=8 --with-log-path-by-env=/data/var --with-jobid-env=NONE cc=/opt/JARVICE_UCX/openmpi/bin/mpicc --prefix=/opt/darshan
make -j 16
make install
sleep 10
cd ..
tar xvfz /tmp/TAR/selfie-1.0.4.tar.gz
cd selfie-1.0.4
./autogen.sh
./configure --with-mpi --with-papi --with-omp --with-posixio --prefix=/opt/selfie
make -j 16
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
