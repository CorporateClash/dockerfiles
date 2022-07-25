FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# use apt mirrors
RUN apt-get update && \
    apt-get install -y libstdc++6 software-properties-common tzdata && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && apt-get update && apt-get -y upgrade && \
    apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    ca-certificates \
    libtool \
    g++ \
    gcc \
    git \
    make \
    wget \
    pkg-config \
    libssl-dev \
    cmake \
    libboost-all-dev \
    libssl-dev \
    libyaml-cpp-dev \
    build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /tmp/bld

RUN wget https://github.com/mongodb/mongo-c-driver/releases/download/1.22.0/mongo-c-driver-1.22.0.tar.gz && tar -xzf mongo-c-driver-1.22.0.tar.gz && cd mongo-c-driver-1.22.0 && cmake . && make && make install
RUN wget https://github.com/mongodb/mongo-cxx-driver/releases/download/r3.6.7/mongo-cxx-driver-r3.6.7.tar.gz && tar -xzf mongo-cxx-driver-r3.6.7.tar.gz && cd mongo-cxx-driver-r3.6.7 && cmake . && make && make install && cp -r install/* /usr/local
RUN wget https://dist.libuv.org/dist/v1.44.2/libuv-v1.44.2.tar.gz && tar -xzf libuv-v1.44.2.tar.gz && ls ./libuv-v1.44.2 && cd libuv-v1.44.2 && ./autogen.sh && ./configure && make && make install


WORKDIR /src

RUN git clone https://github.com/astron/astron . && cd build && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && make && cp astrond /root

RUN mkdir /logs
RUN mkdir /dclass

WORKDIR /root

ENTRYPOINT ["astrond"]
