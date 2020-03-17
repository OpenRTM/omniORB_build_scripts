#!/bin/bash
#
# Script to build omniORB 4.2.3, omniORBpy 4.2.3 and OpenRTM-aist-Python
# in python3 environment of ubuntu 18.04.
#
# Patch the debian directory of omniORB omniORBpy 4.2.2.
# Use this to create a deb package for omniORB and omniORBpy 4.2.3
# in docker environment.
# After that, create a deb package for Python3 of OpenRTM-aist-Python.
#
# Usage:
#   $ sh u1804-build.sh
#   $ ls artifacts
#   libcos4-2_4.2.3-0.1_amd64.deb   libomnithread4-dev_4.2.3-0.1_amd64.deb
#   omniidl_4.2.3-0.1_amd64.deb     omniorb_4.2.3-0.1_amd64.deb
#      :
#   openrtm-aist-python3_1.2.1-1_amd64.deb
#
TARGET=omniorb
OMNI_VER=4.2.3
DIST_NAME=ubuntu1804

OMNI_SHORT_VER=`echo ${OMNI_VER} | sed 's/\.//g'`
IMAGE_NAME=${TARGET}${OMNI_SHORT_VER}-${DIST_NAME}
OMNI_SRC_DIR=${TARGET}-src
OMNIPY_SRC_DIR=${TARGET}py-src
CONTAINER_NAME=rtm-${DIST_NAME}

printf "sudo password: "
stty -echo
read password
stty echo
if test -d ${OMNI_SRC_DIR}; then
  rm -rf ${OMNI_SRC_DIR}
fi
mkdir ${OMNI_SRC_DIR}
if test -d ${OMNIPY_SRC_DIR}; then
  rm -rf ${OMNIPY_SRC_DIR}
fi
mkdir ${OMNIPY_SRC_DIR}

##----- omniORB
cd ${OMNI_SRC_DIR}
wget -O- https://sourceforge.net/projects/omniorb/files/omniORB/omniORB-${OMNI_VER}/omniORB-${OMNI_VER}.tar.bz2 | tar jxvf -
cp ../omniORB-${OMNI_VER}*.patch .
cd -

##---- omniORBpy
cd ${OMNIPY_SRC_DIR}
wget -O- https://sourceforge.net/projects/omniorb/files/omniORBpy/omniORBpy-${OMNI_VER}/omniORBpy-${OMNI_VER}.tar.bz2 | tar jxvf -
cp ../omniORBpy-${OMNI_VER}*.patch .
cd -

##---- OpenRTM-aist-Python
git clone https://github.com/OpenRTM/OpenRTM-aist-Python
cd OpenRTM-aist-Python
git checkout svn/RELENG_1_2
cd -

# Source build in docker environment.
echo "${password}" | sudo -S docker build --build-arg OMNI_VER=${OMNI_VER} -t ${IMAGE_NAME} .
echo "${password}" | sudo -S docker create --name ${CONTAINER_NAME} ${IMAGE_NAME}
echo "${password}" | sudo -S docker cp ${CONTAINER_NAME}:/root/artifacts .
echo "${password}" | sudo -S docker rm ${CONTAINER_NAME}
