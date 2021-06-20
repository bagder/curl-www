#!/bin/sh
#
#  Parse Mozilla's certdata.txt and extract CA Root Certificates into PEM
#  format.
#
#  certdata.txt can be found in Mozilla's source tree:
#  /mozilla/security/nss/lib/ckfw/builtins/certdata.txt
#

if [ $# != 2 ]; then
  echo "Usage: `basename $0` [certdata.txt] [output]"
  exit 1
fi

tmpfile=mytmpfile.txt
header="header"

echo "Processing $1"

tmprb=tmprb.rb

echo "certnum = 1" >> $tmprb
echo >> $tmprb
echo "while line = \$stdin.gets" >> $tmprb
echo "  next if line =~ /^#/" >> $tmprb
echo "  next if line =~ /^\s*$/" >> $tmprb
echo "  line.chomp!" >> $tmprb
echo >> $tmprb
echo "  if line =~ /CKA_LABEL/" >> $tmprb
echo "    label,type,val = line.split(' ',3)" >> $tmprb
echo "    val.sub!(/^\"/, \"\")" >> $tmprb
echo "    val.sub!(/\"$/, \"\")" >> $tmprb
echo "    next" >> $tmprb
echo "  end" >> $tmprb
echo "  if line =~ /CKA_VALUE MULTILINE_OCTAL/" >> $tmprb
echo "    data=''" >> $tmprb
echo "    fname = format \"%d.crt\", certnum" >> $tmprb
echo >> $tmprb
echo "    while line = \$stdin.gets" >> $tmprb
echo "      break if /^END/" >> $tmprb
echo "      line.chomp!" >> $tmprb
echo "      line.gsub(/\\\\([0-3][0-7][0-7])/) { data += \$1.oct.chr }" >> $tmprb
echo "    end" >> $tmprb
echo "    open(fname, \"w\") do |fp|" >> $tmprb
echo "      fp.puts val" >> $tmprb
echo "      fp.puts \"-----BEGIN CERTIFICATE-----\"" >> $tmprb
echo "      fp.puts [data].pack(\"m*\")" >> $tmprb
echo "      fp.puts \"-----END CERTIFICATE-----\"" >> $tmprb
echo "    end" >> $tmprb
echo "    puts \"Parsing: \" + val" >> $tmprb
echo "    certnum += 1" >> $tmprb
echo "  end" >> $tmprb
echo "end" >> $tmprb


chmod 755 $tmprb
cat $1 | ruby ./$tmprb
rm -rf $tmprb

echo "##" > $tmpfile
echo "##  ca-bundle.crt -- Bundle of CA Root Certificates" >> $tmpfile
echo "##  Converted by the service run by Daniel Stenberg" >> $tmpfile
echo "##  URL: https://curl.se/docs/caextract.html" >> $tmpfile
echo "##  Converted at: `date -u`" >> $tmpfile

# insert the version string from the Mozilla source file:
grep "^CVS_ID" $1 | sed -e 's/CVS_ID "@(#) \$RCSfile$ /##  Mozilla: /' >> $tmpfile

echo "##" >> $tmpfile

cat $header >> $tmpfile

files=*.crt

for file in $files; do
  echo "" >> $tmpfile
  name=`sed q $file`
  echo $name >> $tmpfile
  for (( n=0; n<${#name}; ++n ))
  do
    echo -n "=" >> $tmpfile
  done
  echo "" >> $tmpfile
  echo "" >> $tmpfile
  openssl x509 -fingerprint -text -in $file -inform PEM >> $tmpfile
  rm -rf $file
done

mv $tmpfile $2

echo "Done.."
