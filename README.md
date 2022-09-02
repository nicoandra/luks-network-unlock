# How to fix Grub boot:


````
sudo su

cd /mnt
mkdir chroot

cryptsetup luksOpen /dev/sda3 sda3_crypt
mount /dev/vgmint/root chroot
mount /dev/sda2 chroot/boot
mount /dev/sda1 chroot/boot/efi
mount -t proc /proc chroot/proc
mount --rbind /sys chroot/sys
mount --rbind /dev chroot/dev
for i in /dev /dev/pts /proc /sys /run; do sudo mount -B $i /mnt/chroot/$i; done

chroot chroot /bin/bash

grub-install /dev/sda
update-initramfs -k all -u
update-grub -u
````
