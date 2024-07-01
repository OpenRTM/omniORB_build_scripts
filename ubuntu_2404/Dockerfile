FROM ubuntu:24.04 as omniorb-build

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
 libssl-dev \
 debhelper \
 devscripts \
 fakeroot \
 zlib1g-dev \
 dpkg-dev \
 dh-python \
 pkgconf \
 hevea \
 libzstd-dev \
 libomnithread4 \
 libomnithread4-dev \
 libomniorb4-3t64 \
 libomniorb4-dev \
 omniidl \
 omniorb-nameserver \
 omniorb-idl

RUN sed -i -e 's/^# deb-src/deb-src/g' /etc/apt/sources.list \
 && apt update

##### build omniORBpy

ARG OMNIPY_TOP="omniorbpy-src"

COPY ${OMNIPY_TOP} /root/${OMNIPY_TOP}
WORKDIR /root/${OMNIPY_TOP}
RUN cp -r debian omniORBpy-${OMNI_VER}/

WORKDIR /root/${OMNIPY_TOP}/omniORBpy-${OMNI_VER}
RUN dpkg-buildpackage -b -us -uc -j4

RUN mkdir -p /root/${ARTIFACTS} \
 && cp /root/${OMNIPY_TOP}/*deb /root/${ARTIFACTS}/ \
 && cp /root/${OMNIPY_TOP}/*buildinfo /root/${ARTIFACTS}/ \
 && cp /root/${OMNIPY_TOP}/*changes /root/${ARTIFACTS}/


