FROM ubuntu
MAINTAINER raphael.luta@gmail.com

ADD VERSION /VERSION
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
	libxml2-dev	\
	libev-dev	\
	libevent-dev	\
	libjansson-dev	\
	libjemalloc-dev	\
	cython		\
	python3.4-dev	\
        git             \
        gcc             \
        g++             \
        libpcre3-dev    \
        libcap-dev      \
        libncurses5-dev \
        curl            \
        python-setuptools      \
        ruby           \
        bison          \
        cmake          \
     && apt-get clean   \
     && apt-get autoclean \
     && apt-get remove     

WORKDIR /opt

RUN (curl -sL https://github.com/openssl/openssl/archive/OpenSSL_1_0_2d.tar.gz | tar zxvf -) && mv openssl* openssl 
RUN (curl -sL https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz | tar xzf -) && mv libevent* libevent
RUN (curl -sL https://github.com/tatsuhiro-t/spdylay/releases/download/v1.3.2/spdylay-1.3.2.tar.gz | tar zxvf -) && mv spdylay* spdylay
RUN (curl -sL https://github.com/tatsuhiro-t/nghttp2/releases/download/v1.3.4/nghttp2-1.3.4.tar.gz | tar xzvf -) && mv nghttp2* nghttp2
RUN (curl -sL https://github.com/tatsuhiro-t/wslay/archive/release-1.0.0.tar.gz | tar zxvf -) && mv wslay* wslay
RUN (curl -sL https://github.com/mruby/mruby/archive/1.1.0.tar.gz | tar zxvf - ) && mv mruby* mruby
RUN (curl -sL https://github.com/h2o/h2o/archive/v1.5.0.tar.gz | tar zxvf -) && mv h2o* h2o
RUN (curl -sL https://github.com/wg/wrk/archive/4.0.1.tar.gz | tar zxvf -) && mv wrk* wrk
RUN (curl -sL http://www.haproxy.org/download/1.6/src/haproxy-1.6.0.tar.gz | tar zxvf -) && mv haproxy* haproxy
RUN (curl -sL http://nginx.org/download/nginx-1.9.5.tar.gz | tar zxvf -) && mv nginx* nginx
RUN (curl -sL http://apache.crihan.fr/dist//httpd/httpd-2.4.17.tar.gz | tar zxvf -) && mv httpd* httpd && cd httpd/srclib && \
   (curl -sL http://apache.crihan.fr/dist/apr/apr-1.5.2.tar.gz | tar zxvf -) && ln -s apr-1.5.2 apr && \
   (curl -sL http://apache.crihan.fr/dist/apr/apr-util-1.5.4.tar.gz | tar zxvf -) && ln -s apr-util-1.5.4 apr-util
RUN (curl -sL https://github.com/bagder/curl/releases/download/curl-7_45_0/curl-7.45.0.tar.gz | tar zxvf -) && mv curl* curl

ENV SHELL=/bin/bash
ENV PATH=/usr/local/bin:$PATH
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

RUN cd /opt/openssl && ./config shared enable-threads zlib enable-static-engine --prefix=/usr/local --openssldir=/usr/local && \
    make && make install && \
    echo "/usr/local/lib" > /etc/ld.so.conf.d/openssl.conf && ldconfig && \
    make clean && \
    echo "alias openssl='/usr/local/bin/openssl'" >> /root/.bashrc && \
    . /root/.bashrc ; alias openssl='/usr/local/bin/openssl'

RUN cd libevent && CFLAGS=-I/usr/local/include CXXFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib ./configure --prefix=/usr/local && make -j2 && make install && make clean && echo "/usr/local/lib" > /etc/ld.so.conf.d/libevent.conf && ldconfig

RUN cd spdylay && autoreconf -i && automake && autoconf &&  \
    ./configure OPENSSL_LIBS='-L/usr/local/lib -lssl -lcrypto -levent -levent_openssl' && make install && make clean && ldconfig

RUN cd nghttp2 &&  autoreconf -i && automake && autoconf && \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure --enable-app --with-mruby && \
    make -j2 && make install && make clean && ldconfig

RUN cd wslay && \
    autoreconf -i && automake && autoconf && PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure && \
    perl -pi -e 's/SUBDIRS = lib tests examples doc/SUBDIRS = lib tests examples/g' Makefile && \
    make install && make clean && ldconfig

RUN cd mruby && make && \
   cp build/host/lib/libmruby*.a /usr/local/lib/ && \
   cp -R include/mr* /usr/local/include/ && \
   make clean && ldconfig

RUN  cd curl && autoreconf -i && automake && autoconf && \
     ./configure --prefix=/usr/local --with-ssl=/usr/local --enable-threaded-resolver --with-http2 && \
     make -j2 && make install && make clean && \
     echo "/usr/local/lib" > /etc/ld.so.conf.d/curl.conf && ldconfig 

RUN cd h2o && PKG_CONFIG_PATH=/usr/local/lib/pkgconfig cmake -DWITH_MRUBY=ON -DWITH_BUNDLED_SSL=OFF . && make install && make clean && ldconfig

RUN cd wrk && make && mv wrk /usr/local/bin && make clean

RUN cd haproxy && touch doc/haproxy-en.txt doc/haproxy-fr.txt && \
    make TARGET=linux2628 USE_OPENSSL=1 && \
    make install && make clean && ldconfig

RUN cd nginx && \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure --with-http_ssl_module --with-http_v2_module && \
    make && make install && make clean && ldconfig

RUN cd httpd && \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure --enable-modules-shared=all --enable-mpms-shared="worker event" --with-included-apr && \
    make && make install && make clean && ldconfig
