#!/bin/sh

echo -n "Enter a Common Name to embed in the keys: "
read NAME


sbsign --key ./$NAME.key --cert ./$NAME.crt --output $1-signed $1



