FROM ubuntu:22.04 as omniorb-build

ARG OMNI_VER
ARG ARTIFACTS="artifacts"

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

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
 dpkg-dev \
 dh-python \
 libomnithread4 \
 libomnithread4-dev \
 libomniorb4-2 \
 libomniorb4-dev \
 omniidl \
 omniorb-nameserver \
 omniorb-idl

RUN sed -i -e 's/^# deb-src/deb-src/g' /etc/apt/sources.list \
 && apt update


##### build omniORBpy

ARG OMNIPY_TOP="omniorbpy-src"

RUN apt install -y --no-install-recommends \
 python-all-dev \
 python-all-dbg 

COPY ${OMNIPY_TOP} /root/${OMNIPY_TOP}
WORKDIR /root/${OMNIPY_TOP}
RUN cp -r debian omniORBpy-${OMNI_VER}/

WORKDIR /root/${OMNIPY_TOP}/omniORBpy-${OMNI_VER}
RUN dpkg-buildpackage -b -us -uc -j4

RUN mkdir -p /root/${ARTIFACTS} \
 && cp /root/${OMNIPY_TOP}/*deb /root/${ARTIFACTS}/ \
 && cp /root/${OMNIPY_TOP}/*buildinfo /root/${ARTIFACTS}/ \
 && cp /root/${OMNIPY_TOP}/*changes /root/${ARTIFACTS}/

##### build OpenRTM-aist-Python 

FROM ubuntu:22.04 as openrtm-build

ARG ARTIFACTS="artifacts"
ARG OMNI_VER

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

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
 fakeroot \
 omniidl \
 libomniorb4-2 \
 libomnithread4
 

COPY --from=omniorb-build /root/${ARTIFACTS} /root/${ARTIFACTS}

WORKDIR /root/${ARTIFACTS}
RUN dpkg -i omniidl-python3_${OMNI_VER}*.deb \
 && dpkg -i python3-omniorb_${OMNI_VER}*.deb \
 && dpkg -i python3-omniorb-omg_${OMNI_VER}*.deb

COPY OpenRTM-aist-Python /root/OpenRTM-aist-Python
WORKDIR /root/OpenRTM-aist-Python
RUN python3 setup.py build \
 && python3 setup.py sdist

WORKDIR /root/OpenRTM-aist-Python/dist
RUN VERSION=`python3 ../setup.py --version` \
 && tar xf OpenRTM-aist-Python-${VERSION}.tar.gz \
 && cd OpenRTM-aist-Python-${VERSION}/packages \
 && make \
 && cp openrtm* /root/${ARTIFACTS}/

