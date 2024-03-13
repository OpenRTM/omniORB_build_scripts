#!/bin/bash
#
# Script to build omniORB 4.2.5, omniORBpy 4.2.5 and OpenRTM-aist-Python
# in python3 environment of Raspberry Pi.
#
# Patch the debian directory of omniORB omniORBpy 4.2.2.
# Use this to create a deb package for omniORB and omniORBpy 4.2.5
# in docker environment.
# After that, create a deb package for Python3 of OpenRTM-aist-Python.
#
# Usage:
#   $ sh raspi-build.sh 
#   $ ls artifacts
#   omniidl-python3_4.2.5-0.1_all.deb           python3-omniorb-dbg_4.2.5-0.1_arm64.deb
#   openrtm2-python3-example_2.0.2-0_arm64.deb  python3-omniorb-doc_4.2.5-0.1_all.deb
#      :
#
TARGET=omniorb
OMNI_VER=4.2.5
ARTIFACTS="artifacts"

OMNI_SHORT_VER=`echo ${OMNI_VER} | sed 's/\.//g'`
OMNIPY_SRC_DIR=${TARGET}py-src
TOP_DIR=`pwd`

if test -d ${OMNIPY_SRC_DIR}; then
  rm -rf ${OMNIPY_SRC_DIR}
fi
mkdir ${OMNIPY_SRC_DIR}

if test -d ${ARTIFACTS}; then
  rm -rf ${ARTIFACTS}
fi
mkdir ${ARTIFACTS}

sudo apt-get install -y python3-all-dev python3-all-dbg doxygen 
sudo apt-get install -y build-essential debhelper devscripts dpkg-dev
sudo apt-get install -y libssl-dev dh-python
sudo apt-get install -y libomnithread4 libomnithread4-dev 
sudo apt-get install -y libomniorb4-2 libomniorb4-dev
sudo apt-get install -y omniidl omniorb-nameserver omniorb-idl
sudo apt-get install -y python3-pip python3.11-venv
sudo apt-get install -y python3-build

sudo sed -i -e 's/^#deb-src/deb-src/g' /etc/apt/sources.list
sudo apt update

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
VERSION=`dpkg-parsechangelog -l packages/deb/debian/changelog --show-field Version | cut -b 1-5`
python3 -m build
cd dist
python3 -m pip install --no-index --prefix=./ OpenRTM_aist_Python-${VERSION}-py3-none-any.whl
mv local/lib/python3*/dist-packages/OpenRTM_aist/examples .
mv local/lib/python3*/dist-packages/OpenRTM_aist* .
mv local/lib/python3*/dist-packages/packages .

cd packages/deb
chmod 775 dpkg_build.sh
./dpkg_build.sh

cp ../openrtm2* ${TOP_DIR}/${ARTIFACTS}/
cd ${TOP_DIR}

