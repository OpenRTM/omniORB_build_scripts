#!/bin/bash
#
# Script to build omniORBpy 4.3.3 and OpenRTM-aist-Python
# in python3 environment of ubuntu 26.04.
#
# Usage:
#   $ sh u2604-build.sh
#   $ ls artifacts
#   omniidl-python3_4.3.3-0.1_all.deb        python3-omniorb-omg_4.3.3-0.1_all.deb
#   python3-omniorb-dbg_4.3.3-0.1_amd64.deb  python3-omniorb_4.3.3-0.1_amd64.deb
#   python3-omniorb-doc_4.3.3-0.1_all.deb
#
TARGET=omniorb
OMNI_VER=4.3.3
DIST_NAME=ubuntu2604

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
cp -r ../debian433py ./debian
cd -


# Source build in docker environment.
echo "${password}" | sudo -S docker build --build-arg OMNI_VER=${OMNI_VER} -t ${IMAGE_NAME} .
echo "${password}" | sudo -S docker create --name ${CONTAINER_NAME} ${IMAGE_NAME}
echo "${password}" | sudo -S docker cp ${CONTAINER_NAME}:/root/artifacts .
echo "${password}" | sudo -S docker rm ${CONTAINER_NAME}
USER_NAME=$(whoami)
echo "${password}" | sudo -S chown -R ${USER_NAME}:${USER_NAME} artifacts
