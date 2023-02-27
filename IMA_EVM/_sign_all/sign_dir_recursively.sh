#!/bin/bash


if [ -z $2 ]; then

    echo "input PASSWORD:"
    read -s PASS

else

    PASS=$2
fi

echo "begin sign $1"

evmctl sign -r --imahash --key /etc/keys/privkey_evm.pem -p$PASS $1

echo "finish sign $1"
