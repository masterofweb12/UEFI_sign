#!/bin/bash

if [ -z $1 ]; then

    echo "input PASSWORD:"
    read -s  PASS

else

    PASS=$1
fi

./sign_dir_recursively.sh /etc/ $PASS


