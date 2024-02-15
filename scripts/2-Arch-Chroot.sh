#!/bin/sh

# Runs inside arch-chroot. This script is executed from 1-ISO-Init.sh which is executed from 0-ISO-Build.sh 

SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcIjMlhHk+GjietfvSXCb6huwkUwtBweW6Ap6+brock" # github.com/vojkovic.keys

# Timezone to Greenwich Mean Time
ln -sf /usr/share/zoneinfo/GMT /etc/localtime
hwclock --systohc

# Set locale
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen 

# Set ssh key
mkdir -p /root/.ssh
echo "$SSH_KEY" > /root/.ssh/authorized_keys

# Download pfetch script to root home directory.
curl -o /root/pfetch.sh https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch
chmod +x /root/pfetch.sh

# Add execute permissions to scripts in /root
chmod +x /root/*.sh
chmod +x /root/system-scripts/*.sh

# Setup BIRD
ip a | awk '/inet6 fe80/ {ip=$2; sub(/\/64$/, "", ip); print ip; exit}'

# Hardern SSHD config by disabling password auth (publickeys only)
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Edit pacman.conf to enable useful things for a server.
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 50/' /etc/pacman.conf

# Download yay package manager and check signature
curl -L -o yay_download.tar.gz "https://github.com/Jguer/yay/releases/download/v12.2.0/yay_12.2.0_x86_64.tar.gz"
echo "57a69ffe3259173acb2b28603301e23519b9770b0041d63fe716562b6b6be91e  yay_download.tar.gz" | sha256sum -c - || exit 1
tar -xzf yay_download.tar.gz

# Install yay package manager and add bash completion and man page
install -Dm755 yay_12.2.0_x86_64/yay /usr/bin/yay
install -Dm644 yay_12.2.0_x86_64/yay.8 /usr/share/man/man8/yay.8
install -Dm644 yay_12.2.0_x86_64/bash /usr/share/bash-completion/completions/yay

# Install yay translations
for lang in ca cs de en es eu fr_FR he id it_IT ja ko pl_PL pt_BR pt ru_RU ru sv tr uk zh_CN zh_TW; do
  install -Dm644 "yay_12.2.0_x86_64/${lang}.mo" /usr/share/locale/${lang}/LC_MESSAGES/yay.mo
done

# Cleanup yay files
rm -f yay_download.tar.gz
rm -rf yay_12.2.0_x86_64

# initramfs
mkinitcpio -P

# boot loader (disable waiting for GRUB)
sed -i 's/GRUB_TIMEOUT=[0-9]\+/GRUB_TIMEOUT=0/' /etc/default/grub
grub-install --target=i386-pc /dev/vda
grub-mkconfig -o /boot/grub/grub.cfg

# Add variable KUBECONFIG to /etc/profile.d/kubeconfig.sh, this is required for k3s
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" | tee -a /etc/profile.d/kubeconfig.sh

# Enable services
systemctl enable tailscaled.service
systemctl enable automatic-update.timer
systemctl enable setup-bgp-dummy-network.service
systemctl enable sshd.service
systemctl enable dhcpcd.service
systemctl enable NetworkManager.service
