#!/bin/bash

server="api.ddc.uk.net"

openssl s_client -servername "$server" -showcerts -verify 5 -connect "$server":443 < /dev/null | awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ if(/BEGIN CERTIFICATE/){a++}; out="cert"a".pem"; print >out}'
leaf_cert=$(echo cert*.pem | cut -d ' ' -f 1)
mv "$leaf_cert" "leaf_certificate.pem"
for cert in cert*.pem; do
    if [ "$cert" != "leaf_certificate.pem" ]; then
        mv "$cert" "intermediate.pem"
    fi
done
for cert_file in *.pem; do
     echo "SHA256 base64 hash for $cert_file:"
     openssl x509 -in "$cert_file" -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
     echo "--------------------------------------"
 done
 openssl verify -show_chain  -untrusted intermediate.pem leaf_certificate.pem
rm *.pem
