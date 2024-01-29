#!/bin/sh

# Runs inside arch-chroot. This script is executed from iso_execute.sh which is executed from build_iso.sh 

SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcIjMlhHk+GjietfvSXCb6huwkUwtBweW6Ap6+brock"

# Timezone to Greenwich Mean Time
ln -sf /usr/share/zoneinfo/GMT /etc/localtime
hwclock --systohc

# Set locale
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

# Set hostname to country of server by quering https://ipapi.co/country which returns a two letter country code (i.e. AU). Convert cc to lowercase.
echo $(curl -s https://ipapi.co/country) | tr '[:upper:]' '[:lower:]' > /etc/hostname

# Set ssh key
mkdir -p /root/.ssh
echo "$SSH_KEY" > /root/.ssh/authorized_keys

# initramfs
mkinitcpio -P

# boot loader
grub-install --target=i386-pc /dev/vda
grub-mkconfig -o /boot/grub/grub.cfg

# Enable services
systemctl enable sshd
systemctl enable dhcpcd
systemctl enable NetworkManager
systemctl enable cronie

# Exit chroot
exit

# Unmount filesystems
umount -R /mnt
swapoff -a

# Reboot
shutdown -r now