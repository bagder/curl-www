#!/bin/sh

# get the cert and create ca-bundle.crt
perl ../cvssource/scripts/mk-ca-bundle.pl

sha256sum -c cacert.pem.sha256
if test $? -gt "0"; then
  # PEM was updated, save this by date
  d="$(date +%Y-%m-%d)"
  sha256sum cacert.pem > cacert.pem.sha256
  cp cacert.pem "cacert-${d}.pem"
  sed "s/cacert.pem/cacert-${d}.pem/" < cacert.pem.sha256 > "cacert-${d}.pem.sha256"
  gzip -c cacert.pem > cacert.pem.gz
  xz -c cacert.pem > cacert.pem.xz
  perl ./listpem.pl > pemlist.gen
  make
fi
