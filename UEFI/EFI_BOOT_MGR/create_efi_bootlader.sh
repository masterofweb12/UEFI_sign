#!/bin/sh

efibootmgr -c -L "ubuntu signed code" -l '\EFI\ubuntu\vmlinuz'

