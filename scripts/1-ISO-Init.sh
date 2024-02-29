#!/bin/sh

# Refresh arch keyring
rm -r /etc/pacman.d/gnupg/
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
pacstrap -K /mnt base linux mtr git btop bird age curl vim dhcpcd helm helmfile sops grub openssh tailscale networkmanager fakeroot jq pahole

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Copy 2-Arch-Chroot.sh to new system
cp 2-Arch-Chroot.sh /mnt/root/2-Arch-Chroot.sh

# Copy systemd services to new system
cp -rf ../files/systemd/* /mnt/etc/systemd/system/

# Copy root files to new system
cp -rf ../files/root/* /mnt/root/

# Copy configuration files to new system
cp -rf ../files/etc/* /mnt/etc/

# Copy across /etc/hostname from live system (set by cloud-init)
cp -rf /etc/hostname /mnt/etc/hostname

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
# 2-Arch-Chroot now runs inside of the new system
# ...


# Cleanup files
rm -f /mnt/root/2-Arch-Chroot.sh
rm -f /mnt/root/.bashrc

# Unmount filesystems
umount -R /mnt
swapoff -a

echo "--- Installation complete ---"
echo "You can now reboot into your new system."
echo "Please make sure to unmount the ISO before proceeding."
