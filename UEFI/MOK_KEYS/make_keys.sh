#!/bin/sh

echo -n "Enter a Common Name to embed in the keys: "
read NAME

openssl req -new -x509 -newkey rsa:4096 -subj "/CN=$NAME/" -keyout $NAME.key -out $NAME.crt -days 36500 -nodes -sha256
openssl x509 -in $NAME.crt  -out $NAME.cer  -outform DER

GUID=$(uuidgen)
echo $GUID > $NAME.GUID.txt

sbsiglist --owner $GUID --type x509 --output $NAME.cer.siglist $NAME.cer

mkdir -p ./keys/PK/
mkdir -p ./keys/KEK/
mkdir -p ./keys/db/
mkdir -p ./keys/dbx/

for n in PK KEK db
do
   sbvarsign --key $NAME.key --cert $NAME.crt --output ./keys/$n/$n.signed $n $NAME.cer.siglist
done


