#!/bin/bash

urldecode(){
  echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
}

ipextract(){
   grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -u 
}

emailextract(){
   grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" | sort -u
}

urlextracted(){
  grep -oE '\b(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]' | sort -u
}

for file in *.msg; do
  echo 'Filename: ' ${file}
  echo '--------------------'
  echo 'IP Addresses Extracted:'
echo 
echo '-----------------------------------------------------'
echo
strings $file | ipextract
echo
echo 'Email Addresses Extracted:'
echo
echo '-----------------------------------------------------'
echo
strings $file | emailextract
echo
echo '-----------------------------------------------------'
echo
echo 'URLs Extracted:'
echo
echo '-----------------------------------------------------'
strings $file | urlextracted
echo
echo '-----------------------------------------------------'
echo
echo 'Malicious SMTP Server Found'
echo
strings $file | grep 'mailgun'
strings $file | grep 'smtp2go'
echo
echo
echo '------------------------------------------------------'
echo 
echo 'Base64 Encoded Text:'
echo
echo '-------------------------------------------------------'
strings $file > extracted-strings.txt
sed -n '/base64/,/------/p' extracted-strings.txt | sed '/^$/d' | sed '1d' | head -n -1 | base64 --decode
sed -n '/base64/,/------/p' extracted-strings.txt | sed '/^$/d' | sed '1d' | head -n -1 | base64 --decode > decoded-text.txt
echo
echo '--------------------------------------------------------'
echo
echo 'Extracted Links:'
echo
echo '---------------------------------------------------------'
echo
cat decoded-text.txt  | grep -oE '\b(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]' | sort -u | urldecode
shred -n 9 -z -u decoded-text.txt extracted-strings.txt 
done
