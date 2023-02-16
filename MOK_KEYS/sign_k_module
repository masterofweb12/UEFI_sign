#!/bin/sh


echo -n "Enter a Common Name to embed in the keys: "
read NAME


/usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 ./$NAME.key ./$NAME.cer `modinfo -n $1`

tail `modinfo -n $1` | grep "Module signature appendedw"



