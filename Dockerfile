FROM --platform=linux/amd64 centos:7.2.1511

RUN mkdir /data
WORKDIR /data

RUN yum update -y
RUN yum install -y \
          audiofile-devel \
          autoconf \
          automake \
          bind-license \
          cmake \
          cyrus-sasl-lib \
          dbus \
          dbus-libs \
          dos2unix \
          doxygen \
          dpkg-dev \
          dracut \
          epel-release \
          expat \
          gcc \
          gcc-c++ \
          git \
          glib2 \
          glib2-devel \
          gnupg2 \
          gzip \
          krb5-dxevel \
          libatomic \
          libcurl-devel \
          libtool \
          libuuid-devel \
          libxml2 \
          lksctp-tools-devel \
          lsb_release \
          make \
          multilib-rpm-config \
          openssl-devel \
          pkg-config \
          procps-ng \
          python \
          python-libs \
          rpm-build \
          rpmdevtools \
          sqlite \
          unzip \
          uuid-devel \
          vim-minimal \
          wget \
          which \
          xz \
          xz-libs \
          yum-plugin-fastestmirror \
          zlib-devel

ENV CMAKE_VERSION 3.22.2

RUN set -ex \
  && curl -kfsSLO --compressed https://cmake.org/files/v3.22/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz \
  && curl -kfsSLO --compressed https://cmake.org/files/v3.22/cmake-${CMAKE_VERSION}-SHA-256.txt \
  && grep "cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz\$" cmake-${CMAKE_VERSION}-SHA-256.txt | sha256sum -c - \
  && tar xzf cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz -C /usr/local --strip-components=1 --no-same-owner \
  && rm -rf cmake-${CMAKE_VERSION}* \
  && cmake --version

COPY run.sh run.sh
RUN chmod 755 run.sh && dos2unix run.sh
CMD ["sh", "/data/run.sh"]
