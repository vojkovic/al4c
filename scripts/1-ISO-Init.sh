#!/bin/sh

# Refresh arch keyring
pacman-key --init
pacman-key --populate

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

# Copy 2-Arch-Chroot.sh to new system
cp 2-Arch-Chroot.sh /mnt/root/2-Arch-Chroot.sh
# Run from .bashrc
cat <<- _EOF_ | tee /mnt/root/.bashrc
  # Run 2-Arch-Chroot.sh on first start
  if [ -f "/root/2-Arch-Chroot.sh" ]; then
    chmod +x /root/2-Arch-Chroot.sh
    /root/2-Arch-Chroot.sh
    exit
  fi
_EOF_

# Chroot into new system
arch-chroot /mnt


# ...
# 2-Arch-Chroot runs inside of the new system
# ...


# Cleanup files
rm -f /mnt/root/2-Arch-Chroot.sh
rm -f /mnt/root/.bashrc

# Copy firstboot services to new system
cp -rf systemd/firstboot/install-xanmod-kernel.service /etc/systemd/system/install-xanmod-kernel.service
systemctl enable install-xanmod-kernel.service

# Unmount filesystems
umount -R /mnt
swapoff -a

echo "Please make sure to unmount the ISO before proceeding."
read -p "Press Enter to continue after unmounting..."

shutdown -r now