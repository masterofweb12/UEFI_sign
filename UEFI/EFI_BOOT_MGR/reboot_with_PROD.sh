#!/bin/bash


efibootmgr -o 0005,0006,0004,0002,0001,0000
echo "REBOOTING..."
sleep 15

reboot