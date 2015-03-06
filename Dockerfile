FROM ubuntu
MAINTAINER raphael.luta@gmail.com

RUN apt-get update

RUN apt-get install -y  \
	make		\
	binutils	\
	autoconf	\
	automake	\
	autotools-dev	\
	libtool		\
	pkg-config	\
	zlib1g-dev	\
	libcunit1-dev	\
	libssl-dev	\
	libxml2-dev	\
	libev-dev	\
	libevent-dev	\
	libjansson-dev	\
	libjemalloc-dev	\
	cython		\
	python3.4-dev	\
        openssl         \
        git             \
        gcc             \
        g++             \
        libpcre3-dev    \
        libcap-dev      \
        libncurses5-dev \
        curl            \
     && apt-get clean   \
     && apt-get autoclean \
     && apt-get remove     

WORKDIR /opt

#RUN git clone --depth 1 https://github.com/openssl/openssl.git
#RUN cd openssl &&           \
#    ./config shared zlib && \
#    make &&                 \
#    make install &&         \
#    make clean

RUN git clone --depth 1 https://github.com/tatsuhiro-t/spdylay.git
RUN cd spdylay &&       \
    autoreconf -i &&    \
    automake &&         \
    autoconf &&         \
    ./configure &&      \
    make &&             \
    make install &&	\
    make clean

RUN git clone --depth 1 https://github.com/tatsuhiro-t/nghttp2.git
RUN cd nghttp2 &&               \
    autoreconf -i &&            \
    automake &&                 \
    autoconf &&                 \
    ./configure --enable-app && \
    make &&                     \
    make install &&		\
    make clean

RUN apt-get install -y squid3 apache2
RUN ldconfig

ADD certs /certs
ADD run.sh /usr/local/bin/run.sh

WORKDIR /var/www
VOLUME ["/var/www","/certs"]

EXPOSE 80 443
