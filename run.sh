#!/bin/bash

mode=${1:-help}
name=${2:-aptiwan.com}

if [ ! -e "/certs/$name.pem" ]
then
    echo "Generating new cert for $name"
    openssl req -new -x509 -subj /C=FR/O=aptiwan/CN=$name -newkey rsa:1024 -days 365 -nodes -keyout /certs/$name.pem -out /certs/$name.crt
fi

case "$mode" in
proxy)
  squid3
  nghttpx -s -b 127.0.0.1,3128 $3 /certs/$name.pem /certs/$name.crt
  ;;
reverse)
  nghttpx -b $name,80 $3 /certs/$name.pem /certs/$name.crt
  ;;
local)
  service apache2 start
  nghttpx $3 /certs/$name.pem /certs/$name.crt
  ;;
*)
  echo "run.sh <proxy|reverse|local> certname"
  ;; 
esac
