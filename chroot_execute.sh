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

# Download pfetch script to root home directory.
curl -o /root/pfetch.sh https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch
chmod +x /root/pfetch.sh

# Install openvpn server, fix error in openvpn permissions on archlinux.
mkdir -p /root/ovpn
curl -o /root/ovpn/openvpn.sh https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x /root/ovpn/openvpn.sh
APPROVE_INSTALL=y APPROVE_IP=y IPV6_SUPPORT=y PORT_CHOICE=1 PROTOCOL_CHOICE=1 DNS=5 COMPRESSION_ENABLED=n CUSTOMIZE_ENC=n CLIENT=client PASS=1 /root/ovpn/openvpn.sh
sed -i '/^user /d; /^group /d' /etc/openvpn/server.conf
chown openvpn:network /etc/openvpn/*
chown openvpn:network /var/log/openvpn
mv /root/client.ovpn /root/ovpn/client.ovpn

# Hardern SSHD config by disabling password auth (publickeys only)
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Enable services
systemctl enable sshd
systemctl enable openvpn-server@server
systemctl enable dhcpcd
systemctl enable NetworkManager
systemctl enable cronie
