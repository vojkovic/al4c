#!/bin/sh

SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcIjMlhHk+GjietfvSXCb6huwkUwtBweW6Ap6+brock"

# Partition drive and format filesystem & format swap (3GiB)
parted -s "/dev/vda" mklabel msdos
parted -s "/dev/vda" mkpart primary 1MiB 29GiB
parted -s "/dev/vda" mkpart primary linux-swap 29GiB 100%
mkfs.ext4 "/dev/vda1"
mkswap "/dev/vda2"

# Mount filesystems and swap
swapon "/dev/vda2"
mount "/dev/vda1" /mnt

# Install base system and install misc basic utilities (mtr, btop, curl, vim, etc.)
pacstrap -K /mnt base linux mtr btop curl vim dhcpcd grub openssh cronie networkmanager

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into new system
arch-chroot /mnt

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