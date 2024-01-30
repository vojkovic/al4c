#!/bin/sh

# Refresh arch keyring
pacman -Sy archlinux-keyring --noconfirm

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
pacstrap -K /mnt base linux mtr git btop curl vim dhcpcd grub openssh cronie networkmanager fakeroot jq pahole

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Copy chroot_execute.sh to new system
cp chroot_execute.sh /mnt/root/chroot_execute.sh

# Run from .bashrc
cat <<- _EOF_ | tee /mnt/root/.bashrc
  # Run chroot_execute.sh on first start
  if [ -f "/root/chroot_execute.sh" ]; then
    chmod +x /root/chroot_execute.sh
    /root/chroot_execute.sh
    exit
  fi
_EOF_

# Chroot into new system
arch-chroot /mnt

# Cleanup files
rm -f /mnt/root/chroot_execute.sh
rm -f /mnt/root/.bashrc

# Copy chroot_execute.sh to new system
cp first_boot.sh /mnt/root/first_boot.sh

# Run from .bashrc
cat <<- _EOF_ | tee /mnt/root/.bashrc
  # Run first_boot.sh on first start
  if [ -f "/root/first_boot.sh" ]; then
    chmod +x /root/first_boot.sh
    /root/first_boot.sh
    rm -rf /root/first_boot.sh
    rm -f /root/.bashrc && touch /root/.bashrc && reboot
  fi
_EOF_

# Unmount filesystems
umount -R /mnt
swapoff -a

# Reboot
shutdown -r now