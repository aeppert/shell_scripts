#!/bin/sh
#
# From: http://people.skolelinux.org/pere/blog/Public_Trusted_Timestamping_services_for_everyone.html
#
set -e
url="http://zeitstempel.dfn.de"
caurl="https://pki.pca.dfn.de/global-services-ca/pub/cacert/chain.txt"
reqfile=$(mktemp -t tmp.XXXXXXXXXX.tsq)
resfile=$(mktemp -t tmp.XXXXXXXXXX.tsr)
cafile=chain.txt
if [ ! -f $cafile ] ; then
    wget -O $cafile "$caurl"
fi
openssl ts -query -data "$1" -cert | tee "$reqfile" \
    | /usr/lib/ssl/misc/tsget -h "$url" -o "$resfile"
openssl ts -reply -in "$resfile" -text 1>&2
openssl ts -verify -data "$1" -in "$resfile" -CAfile "$cafile" 1>&2
base64 < "$resfile"
rm "$reqfile" "$resfile"
