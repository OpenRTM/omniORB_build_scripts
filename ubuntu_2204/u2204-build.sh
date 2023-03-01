#!/bin/bash
#
# Script to build omniORBpy 4.2.5 and OpenRTM-aist-Python
# in python3 environment of ubuntu 22.04.
#
# Patch the debian directory of omniORBpy 4.2.2.
# Use this to create a deb package for omniORBpy 4.2.5
# in docker environment.
# After that, create a deb package for Python3 of OpenRTM-aist-Python.
#
# Usage:
#   $ sh u2004-build.sh
#   $ ls artifacts
#   omniidl-python3_4.2.5-0.1_all.deb         python3-omniorb_4.2.5-0.1_amd64.deb 
#   python3-omniorb-dbg_4.2.5-0.1_amd64.deb   python3-omniorb-omg_4.2.5-0.1_all.deb
#      :
#   openrtm2-python3_2.0.1-0_amd64.deb        openrtm2-python3-example_2.0.1-0_amd64.deb
#
TARGET=omniorb
OMNI_VER=4.2.5
DIST_NAME=ubuntu2204

OMNI_SHORT_VER=`echo ${OMNI_VER} | sed 's/\.//g'`
IMAGE_NAME=${TARGET}${OMNI_SHORT_VER}-${DIST_NAME}
OMNIPY_SRC_DIR=${TARGET}py-src
CONTAINER_NAME=rtm-${DIST_NAME}

printf "sudo password: "
stty -echo
read password
stty echo
if test -d ${OMNIPY_SRC_DIR}; then
  rm -rf ${OMNIPY_SRC_DIR}
fi
mkdir ${OMNIPY_SRC_DIR}

#---- omniORBpy
cd ${OMNIPY_SRC_DIR}
wget -O- https://sourceforge.net/projects/omniorb/files/omniORBpy/omniORBpy-${OMNI_VER}/omniORBpy-${OMNI_VER}.tar.bz2 | tar jxvf -
cp -r ../debian .
cd -

#---- OpenRTM-aist-Python
git clone https://github.com/OpenRTM/OpenRTM-aist-Python

# Source build in docker environment.
echo "${password}" | sudo -S docker build --build-arg OMNI_VER=${OMNI_VER} -t ${IMAGE_NAME} .
echo "${password}" | sudo -S docker create --name ${CONTAINER_NAME} ${IMAGE_NAME}
echo "${password}" | sudo -S docker cp ${CONTAINER_NAME}:/root/artifacts .
echo "${password}" | sudo -S docker rm ${CONTAINER_NAME}
