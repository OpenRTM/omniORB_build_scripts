#!/bin/bash
#
# Script to build omniORB 4.2.4, omniORBpy 4.2.4 and OpenRTM-aist-Python
# in python3 environment of Raspberry Pi.
#
# Patch the debian directory of omniORB omniORBpy 4.2.2.
# Use this to create a deb package for omniORB and omniORBpy 4.2.4
# in docker environment.
# After that, create a deb package for Python3 of OpenRTM-aist-Python.
#
# Usage:
#   $ sh raspi-build.sh 
#   $ ls artifacts
#   libcos4-2_4.2.4-0.1_armhf.deb   libomnithread4-dev_4.2.4-0.1_armhf.deb
#   omniidl_4.2.4-0.1_armhf.deb     omniorb_4.2.4-0.1_armhf.deb
#      :
#   openrtm-aist-python3_1.2.2-0_armhf.deb
#
TARGET=omniorb
OMNI_VER=4.2.4
DIST_NAME=raspi_bullseye
OMNI_APT_SRC="omniorb-dfsg-4.2.2"
ARTIFACTS="artifacts"

OMNI_SHORT_VER=`echo ${OMNI_VER} | sed 's/\.//g'`
IMAGE_NAME=${TARGET}${OMNI_SHORT_VER}-${DIST_NAME}
OMNI_SRC_DIR=${TARGET}-src
OMNIPY_SRC_DIR=${TARGET}py-src
TOP_DIR=`pwd`

if test -d ${OMNI_SRC_DIR}; then
  rm -rf ${OMNI_SRC_DIR}
fi
mkdir ${OMNI_SRC_DIR}

if test -d ${OMNIPY_SRC_DIR}; then
  rm -rf ${OMNIPY_SRC_DIR}
fi
mkdir ${OMNIPY_SRC_DIR}

if test -d ${ARTIFACTS}; then
  rm -rf ${ARTIFACTS}
fi
mkdir ${ARTIFACTS}

sudo apt install -y python3-all-dev python3-all-dbg doxygen 
sudo apt install -y build-essential debhelper devscripts dpkg-dev
sudo apt install -y libssl-dev python-all-dbg dh-python
sudo apt install -y python-all-dev python-all-dbg

sudo sed -i -e 's/^#deb-src/deb-src/g' /etc/apt/sources.list
sudo apt update

##----- omniORB
cd ${OMNI_SRC_DIR}
wget -O- https://sourceforge.net/projects/omniorb/files/omniORB/omniORB-${OMNI_VER}/omniORB-${OMNI_VER}.tar.bz2 | tar jxvf -
apt source omniorb
cp -r ${OMNI_APT_SRC}/debian omniORB-${OMNI_VER}/
patch -d omniORB-${OMNI_VER}/debian < ../omniORB-${OMNI_VER}_debian.patch
cd omniORB-${OMNI_VER} 
dpkg-buildpackage -b -us -uc
cd -

cp omni*deb ${TOP_DIR}/${ARTIFACTS}/
cp omni*buildinfo ${TOP_DIR}/${ARTIFACTS}/
cp omni*changes ${TOP_DIR}/${ARTIFACTS}/
cp lib*.deb ${TOP_DIR}/${ARTIFACTS}/

sudo dpkg -i libomnithread4_${OMNI_VER}*.deb
sudo dpkg -i libomniorb4-2_${OMNI_VER}*.deb
sudo dpkg -i libomnithread4-dev_${OMNI_VER}*.deb
sudo dpkg -i libomniorb4-dev_${OMNI_VER}*.deb
sudo dpkg -i omniidl_${OMNI_VER}*.deb
sudo dpkg -i omniorb-nameserver_${OMNI_VER}*.deb
sudo dpkg -i omniorb-idl_${OMNI_VER}*.deb
cd -

##---- omniORBpy
cd ${OMNIPY_SRC_DIR}
wget -O- https://sourceforge.net/projects/omniorb/files/omniORBpy/omniORBpy-${OMNI_VER}/omniORBpy-${OMNI_VER}.tar.bz2 | tar jxvf -
cp -r ${TOP_DIR}/debian omniORBpy-${OMNI_VER}/
patch -d omniORBpy-${OMNI_VER}/debian < ../omniORBpy-${OMNI_VER}_debian.patch 
cd omniORBpy-${OMNI_VER}
dpkg-buildpackage -b -us -uc
cd -

cp *deb ${TOP_DIR}/${ARTIFACTS}/
cp *buildinfo ${TOP_DIR}/${ARTIFACTS}/
cp *changes ${TOP_DIR}/${ARTIFACTS}/

sudo dpkg -i omniidl-python3_${OMNI_VER}*.deb
sudo dpkg -i python3-omniorb_${OMNI_VER}*.deb
sudo dpkg -i python3-omniorb-omg_${OMNI_VER}*.deb
cd -

##---- OpenRTM-aist-Python
git clone https://github.com/OpenRTM/OpenRTM-aist-Python
cd OpenRTM-aist-Python

python3 setup.py build
python3 setup.py sdist

cd dist
VERSION=`python3 ../setup.py --version`
tar xf OpenRTM-aist-Python-${VERSION}.tar.gz
cd OpenRTM-aist-Python-${VERSION}/packages
make
cp openrtm2* ${TOP_DIR}/${ARTIFACTS}/

cd ${TOP_DIR}

