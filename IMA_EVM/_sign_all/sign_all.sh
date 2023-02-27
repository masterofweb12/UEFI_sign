#!/bin/bash

if [ -z $1 ]; then

    echo "input PASSWORD:"
    read -s PASS

else

    PASS=$1
fi


./sign_dir_recursively.sh /usr/bin/ $PASS
./sign_dir_recursively.sh /usr/sbin/ $PASS

./sign_dir_recursively.sh /etc/ $PASS

./sign_dir_recursively.sh /usr/lib/ $PASS
./sign_dir_recursively.sh /usr/lib64/ $PASS
./sign_dir_recursively.sh /usr/lib32/ $PASS
./sign_dir_recursively.sh /usr/libx32/ $PASS

./sign_dir_recursively.sh /usr/share/ $PASS

./sign_dir_recursively.sh /root/UEFI_IMA/ $PASS