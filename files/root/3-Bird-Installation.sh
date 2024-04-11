#!/bin/bash

# Find and replace placeholder values in /etc/bird.conf
# Requires age secret key to be present in /root/.config/age/key.txt

# Check /root/.config/age/key.txt exists
if [ ! -f /root/.config/age/key.txt ]; then
  echo "age secret key not found at /root/.config/age/key.txt"
  exit 1
fi

echo "Enter the public v6 address as provided in the Vultr Control Panel i.e. 2001:19f0:5801:0ddb:5420:04ff:fe32:02b0"
read PUBLICV6

ip address add $PUBLICV6/64 dev ens3

BGPPASSWORD=$(cat /etc/bird-password.age | age --decrypt -i /root/.config/age/key.txt)
LINKLOCAL=$(ip a | awk '/inet6 fe80/ {ip=$2; sub(/\/64$/, "", ip); print ip; exit}')
PUBLICV4=$(curl -s https://v4.ident.me)

sed -i "s/PLACEHOLDER-REPLACE-WITH-PUBLIC-VULTR-ASSIGNED-IPV4-ADDRESS/$PUBLICV4/" /etc/bird.conf
sed -i "s/PLACEHOLDER-REPLACE-WITH-PUBLIC-VULTR-ASSIGNED-IPV6-ADDRESS/$PUBLICV6/" /etc/bird.conf
sed -i "s/PLACEHOLDER-REPLACE-WITH-LINK-LOCAL-ADDRESS/$LINKLOCAL/" /etc/bird.conf
sed -i "s/PLACEHOLDER-REPLACE-WITH-PASSWORD/$BGPPASSWORD/" /etc/bird.conf

# Remove bird-password.age as it is no longer needed
rm /etc/bird-password.age

# Enable BIRD and enable setup-bgp-dummy-network.service
systemctl enable setup-bgp-dummy-network.service
systemctl enable bird

# Start BIRD
systemctl start bird

# Show status of bird
systemctl status bird

exit 0
