FROM ubuntu:18.04 as omni-src 

ARG OMNI_TOP="omniorb-src"
ARG OMNI_VER
ARG OMNI_APT_SRC="omniorb-dfsg-4.2.2"
ARG OMNIPY_TOP="omniorbpy-src"
ARG OMNIPY_APT_SRC="python-omniorb-4.2.2"
ARG ARTIFACTS="artifacts"

RUN apt update\
 && apt install -y --no-install-recommends \
 dpkg-dev

RUN sed -i -e 's/^# deb-src/deb-src/g' /etc/apt/sources.list \
 && apt update

COPY ${OMNI_TOP} /root/${OMNI_TOP}
WORKDIR /root/${OMNI_TOP}
RUN apt source omniorb \
 && cp -r ${OMNI_APT_SRC}/debian omniORB-${OMNI_VER}/ \
 && patch -d omniORB-${OMNI_VER}/debian < omniORB-${OMNI_VER}_debian.patch

COPY ${OMNIPY_TOP} /root/${OMNIPY_TOP}
WORKDIR /root/${OMNIPY_TOP}
RUN apt source python-omniorb \
 && cp -r ${OMNIPY_APT_SRC}/debian omniORBpy-${OMNI_VER}/ \
 && patch -d omniORBpy-${OMNI_VER}/debian < omniORBpy-${OMNI_VER}_debian.patch

##### build omniORB and omniORBpy

FROM ubuntu:16.04 as omniorb-build

ARG OMNI_TOP="omniorb-src"
ARG OMNI_VER
ARG ARTIFACTS="artifacts"

RUN apt update\
 && apt install -y --no-install-recommends \
 python3 \
 python3-all-dev \
 python3-all-dbg \
 doxygen \
 build-essential \
 pkg-config \
 libssl-dev \
 debhelper \
 devscripts \
 fakeroot \
 zlib1g-dev \
 dh-autoreconf \
 dpkg-dev

COPY --from=omni-src /root/${OMNI_TOP} /root/${OMNI_TOP}

WORKDIR /root/${OMNI_TOP}/omniORB-${OMNI_VER}
RUN dpkg-buildpackage -b -us -uc 

RUN mkdir -p /root/${ARTIFACTS} \
 && cp /root/${OMNI_TOP}/omni*deb /root/${ARTIFACTS}/ \
 && cp /root/${OMNI_TOP}/omni*changes /root/${ARTIFACTS}/ \
 && cp /root/${OMNI_TOP}/lib*.deb /root/${ARTIFACTS}/

WORKDIR /root/${ARTIFACTS}
RUN dpkg -i libomnithread4_${OMNI_VER}*.deb \
 && dpkg -i libomniorb4-2_${OMNI_VER}*.deb \
 && dpkg -i libomnithread4-dev_${OMNI_VER}*.deb \
 && dpkg -i libomniorb4-dev_${OMNI_VER}*.deb \
 && dpkg -i omniidl_${OMNI_VER}*.deb \
 && dpkg -i omniorb-nameserver_${OMNI_VER}*.deb \
 && dpkg -i omniorb-idl_${OMNI_VER}*.deb

##### build omniORBpy

ENV OMNIPY_TOP="omniorbpy-src"

COPY --from=omni-src /root/${OMNIPY_TOP} /root/${OMNIPY_TOP}

RUN apt install -y --no-install-recommends \
 python-all-dev \
 python-all-dbg

WORKDIR /root/${OMNIPY_TOP}/omniORBpy-${OMNI_VER}
RUN dpkg-buildpackage -b -us -uc

RUN cp /root/${OMNIPY_TOP}/*deb /root/${ARTIFACTS}/ \
 && cp /root/${OMNIPY_TOP}/*changes /root/${ARTIFACTS}/

##### build OpenRTM-aist-Python 

FROM ubuntu:16.04 as openrtm-build

ARG ARTIFACTS="artifacts"
ARG OMNI_VER

RUN apt update\
 && apt install -y --no-install-recommends \
 python3 \
 python3-all-dev \
 doxygen \
 graphviz \
 pkg-config \
 libssl-dev \
 build-essential \
 debhelper \
 devscripts \
 fakeroot

COPY --from=omniorb-build /root/${ARTIFACTS} /root/${ARTIFACTS}

WORKDIR /root/${ARTIFACTS}
RUN dpkg -i libomnithread4_${OMNI_VER}*.deb \
 && dpkg -i libomniorb4-2_${OMNI_VER}*.deb \
 && dpkg -i omniidl_${OMNI_VER}*.deb \
 && dpkg -i omniidl-python3_${OMNI_VER}*.deb \
 && dpkg -i python3-omniorb_${OMNI_VER}*.deb \
 && dpkg -i python3-omniorb-omg_${OMNI_VER}*.deb

COPY OpenRTM-aist-Python /root/OpenRTM-aist-Python
WORKDIR /root/OpenRTM-aist-Python
RUN sed -i -e "s/('build_doc'/#('build_doc'/g" setup.py \
 && sed -i -e 's%(mkdir $(CURDIR)/debian/openrtm-aist-python3-doc%#(mkdir $(CURDIR)/debian/openrtm-aist-python3-doc%g' packages/deb/debian/rules \
 && sed -i -e 's/python3 setup.py install_doc/#python3 setup.py install_doc/g' packages/deb/debian/rules \
 && mv packages/deb/debian/control packages/deb/debian/control.back \
 && cat packages/deb/debian/control.back | head -n 27 > packages/deb/debian/control \
 && python3 setup.py build \
 && python3 setup.py sdist

WORKDIR /root/OpenRTM-aist-Python/dist
RUN VERSION=`python3 ../setup.py --version` \
 && tar xf OpenRTM-aist-Python-${VERSION}.tar.gz \
 && cd OpenRTM-aist-Python-${VERSION}/packages \
 && make \
 && cp openrtm-aist* /root/${ARTIFACTS}/

