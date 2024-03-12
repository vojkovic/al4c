#!/bin/bash

# Install K3s server with tailscale
# Requires age secret key to be present in /root/.config/sops/age/keys.txt

# Check /root/.config/sops/age/keys.txt exists
if [ ! -f /root/.config/sops/age/keys.txt ]; then
  echo "age secret key not found at /root/.config/sops/age/keys.txt"
  exit 1
fi

# Ask user for K3s token
echo "Enter the K3s token:"
read TOKEN

# Ask user for K3s server
echo "Enter the K3s server (i.e. https://myserver:6443):"
read K3S_SERVER

# Set ZONE to the hostname of the machine
ZONE=$(cat /etc/hostname)

# Get Tailscale key from age encrypted file
TSKEY=$(cat /root/secrets/tailscale-key.age | age --decrypt -i /root/.config/sops/age/keys.txt)

# Get public IPv4 and IPv6 addresses
PUBLICV4=$(curl -s https://v4.ident.me)
PUBLICV6=$(curl -s https://v6.ident.me)


# Install our Kubernetes Distribution (K3s) with Tailscale
curl -sfL https://get.k3s.io | K3S_TOKEN=$TOKEN sh -s - agent \
    "--server=$K3S_SERVER" \
    "--node-name=$ZONE" \
    "--node-label=failure-domain.beta.kubernetes.io/zone=$ZONE" \
    "--node-external-ip=$PUBLICV4" \
    "--node-external-ip=$PUBLICV6" \
    "--vpn-auth="name=tailscale,joinKey=$TSKEY""

# Install helm plugins
helm plugin install https://github.com/databus23/helm-diff
helm plugin install https://github.com/jkroepke/helm-secrets

exit 0
