#!/bin/sh


echo ""
echo "/sys/kernel/security/integrity/ima/policy"
echo "-----------------------------------------"
cat /sys/kernel/security/integrity/ima/policy
echo ""
echo ""


echo ""
echo "/sys/kernel/security/integrity/evm/evm"
echo "--------------------------------------"
cat /sys/kernel/security/integrity/evm/evm
echo ""
echo ""
