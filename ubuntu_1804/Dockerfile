FROM ubuntu:18.04 as omniorb-build

ENV OMNI_TOP="omniorb-src"
ENV OMNI_SRC="omniORB-4.2.3"
ENV OMNI_APT_SRC="omniorb-dfsg-4.2.2"
ENV ARTIFACTS="artifacts"

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
 dpkg-dev

RUN sed -i -e 's/^# deb-src/deb-src/g' /etc/apt/sources.list \
 && apt update

COPY ${OMNI_TOP} /root/${OMNI_TOP}
WORKDIR /root/${OMNI_TOP}
RUN apt source omniorb \
 && cp -r ${OMNI_APT_SRC}/debian ${OMNI_SRC}/ \
 && patch -d ${OMNI_SRC}/debian < ${OMNI_SRC}_debian.patch 

WORKDIR /root/${OMNI_TOP}/${OMNI_SRC}
RUN dpkg-buildpackage -b -us -uc 

RUN mkdir -p /root/${ARTIFACTS} \
 && cp /root/${OMNI_TOP}/omni*deb /root/${ARTIFACTS}/ \
 && cp /root/${OMNI_TOP}/omni*buildinfo /root/${ARTIFACTS}/ \
 && cp /root/${OMNI_TOP}/omni*changes /root/${ARTIFACTS}/ \
 && cp /root/${OMNI_TOP}/lib*.deb /root/${ARTIFACTS}/

WORKDIR /root/${ARTIFACTS}
RUN dpkg -i libomnithread4_4.2.3-0.1_amd64.deb \
 && dpkg -i libomniorb4-2_4.2.3-0.1_amd64.deb \
 && dpkg -i libomnithread4-dev_4.2.3-0.1_amd64.deb \
 && dpkg -i libomniorb4-dev_4.2.3-0.1_amd64.deb \
 && dpkg -i omniidl_4.2.3-0.1_amd64.deb \
 && dpkg -i omniorb-nameserver_4.2.3-0.1_amd64.deb \
 && dpkg -i omniorb-idl_4.2.3-0.1_all.deb

##### build omniORBpy

ENV OMNIPY_TOP="omniorbpy-src"
ENV OMNIPY_SRC="omniORBpy-4.2.3"
ENV OMNIPY_APT_SRC="python-omniorb-4.2.2"

RUN apt install -y --no-install-recommends \
 python-all-dev \
 python-all-dbg 

COPY ${OMNIPY_TOP} /root/${OMNIPY_TOP}
WORKDIR /root/${OMNIPY_TOP}
RUN apt source python-omniorb \
 && cp -r ${OMNIPY_APT_SRC}/debian ${OMNIPY_SRC}/ \
 && patch -d ${OMNIPY_SRC}/debian < ${OMNIPY_SRC}_debian.patch 

WORKDIR /root/${OMNIPY_TOP}/${OMNIPY_SRC}
RUN dpkg-buildpackage -b -us -uc

RUN cp /root/${OMNIPY_TOP}/*deb /root/${ARTIFACTS}/ \
 && cp /root/${OMNIPY_TOP}/*buildinfo /root/${ARTIFACTS}/ \
 && cp /root/${OMNIPY_TOP}/*changes /root/${ARTIFACTS}/

##### build OpenRTM-aist-Python 

FROM ubuntu:18.04 as openrtm-build

ENV ARTIFACTS="artifacts"

RUN apt update\
 && apt install -y --no-install-recommends \
 python3 \
 python3-all-dev \
 doxygen \
 pkg-config \
 libssl-dev \
 build-essential \
 debhelper \
 devscripts \
 fakeroot

COPY --from=omniorb-build /root/${ARTIFACTS} /root/${ARTIFACTS}

WORKDIR /root/${ARTIFACTS}
RUN dpkg -i libomnithread4_4.2.3-0.1_amd64.deb \
 && dpkg -i libomniorb4-2_4.2.3-0.1_amd64.deb \
 && dpkg -i omniidl_4.2.3-0.1_amd64.deb \
 && dpkg -i omniidl-python3_4.2.3-0.1_all.deb \
 && dpkg -i python3-omniorb_4.2.3-0.1_amd64.deb \
 && dpkg -i python3-omniorb-omg_4.2.3-0.1_all.deb

COPY OpenRTM-aist-Python /root/OpenRTM-aist-Python
WORKDIR /root/OpenRTM-aist-Python
RUN python3 setup.py build \
 && python3 setup.py sdist

WORKDIR /root/OpenRTM-aist-Python/dist
RUN tar xf OpenRTM-aist-Python-1.2.1.tar.gz

WORKDIR OpenRTM-aist-Python-1.2.1/packages
RUN make \ 
 && cp openrtm-aist* /root/${ARTIFACTS}/

