#! /bin/sh


EFIFOLDER='/boot/efi/EFI/ubuntu'


if [ -f "${EFIFOLDER}/vmlinuz"  ]; then

    cat "${EFIFOLDER}/vmlinuz" > "${EFIFOLDER}/vmlinuz.old"
fi



## echo "root=/dev/mapper/root rw quiet splash" > /tmp/cmdline
# evm=fix
##           /dev/mapper/ubuntu--vg-ubuntu--lv
##echo "root=/dev/mapper/ubuntu--vg-ubuntu--lv ro lsm=apparmor,integrity ima_appraise=log integrity_audit=1" > /tmp/cmdline
echo "root=/dev/mapper/ubuntu--vg-ubuntu--lv ro lsm=apparmor,integrity ima_appraise=enforce integrity_audit=1" > /tmp/cmdline

if [ "x$1" != "x" ]; then

objcopy \
  --add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
  --add-section .cmdline=/tmp/cmdline  --change-section-vma .cmdline=0x30000 \
  --add-section .linux=`realpath /boot/vmlinuz-$1`     --change-section-vma .linux=0x2000000 \
  --add-section .initrd=`realpath /boot/initrd.img-$1` --change-section-vma .initrd=0x4000000 \
/usr/lib/systemd/boot/efi/linuxx64.efi.stub "${EFIFOLDER}/vmlinuz"

else

objcopy \
  --add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
  --add-section .cmdline=/tmp/cmdline  --change-section-vma .cmdline=0x30000 \
  --add-section .linux=`realpath /boot/vmlinuz`     --change-section-vma .linux=0x2000000 \
  --add-section .initrd=`realpath /boot/initrd.img` --change-section-vma .initrd=0x4000000 \
/usr/lib/systemd/boot/efi/linuxx64.efi.stub "${EFIFOLDER}/vmlinuz"

fi

rm /tmp/cmdline

exit 0
