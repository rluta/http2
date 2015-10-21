# docker base image for HTTP/2 testing

This image compiles on Ubuntu 14.04 the main HTTP/2 servers and intermediaries against openssl 1.0.2 for ALPN support.

This includes:
  * nghttp 1.3.4 (w/SPDY and Mruby)
  * h2o 1.5.0 (w/Mruby)
  * nginx 1.9.5
  * apache 2.4.17
  * haproxy 1.6.0

Sources are located in */opt*

All built binaries are in /usr/local and don't integrate or interfere with system packages 

This image is meant for HTTP/2 testing and troubleshooting.
