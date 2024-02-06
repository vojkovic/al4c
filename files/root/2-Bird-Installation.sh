#!/bin/bash

# Find and replace placeholder values in /etc/bird.conf
# Requires age secret key to be present in /root/age-key.txt

BGPPASSWORD=$(cat /etc/bird-password.age | age --decrypt -i /root/age-key.txt)
LINKLOCAL=$(ip a | awk '/inet6 fe80/ {ip=$2; sub(/\/64$/, "", ip); print ip; exit}')
PUBLICV4=$(curl -s https://v4.ident.me)
PUBLICV6=$(curl -s https://v6.ident.me)

sed -i "s/PLACEHOLDER-REPLACE-WITH-PUBLIC-VULTR-ASSIGNED-IPV4-ADDRESS/$PUBLICV4/" /etc/bird.conf
sed -i "s/PLACEHOLDER-REPLACE-WITH-PUBLIC-VULTR-ASSIGNED-IPV6-ADDRESS/$PUBLICV6/" /etc/bird.conf
sed -i "s/PLACEHOLDER-REPLACE-WITH-LINK-LOCAL-ADDRESS/$LINKLOCAL/" /etc/bird.conf
sed -i "s/PLACEHOLDER-REPLACE-WITH-PASSWORD/$BGPPASSWORD/" /etc/bird.conf

# Remove bird-password.age as it is no longer needed
rm /etc/bird-password.age

# Enable BIRD
systemctl enable bird

# Start BIRD
systemctl start bird

# Show status of bird
systemctl status bird

exit 0