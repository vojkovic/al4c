#!/bin/bash

# Install K3s server with tailscale
# Requires age secret key to be present in /root/.config/sops/age/keys.txt

ZONE="eu-frankfurt-1"
REGION="vultrfra"

# Check /root/.config/sops/age/keys.txt exists
if [ ! -f /root/.config/sops/age/keys.txt ]; then
  echo "age secret key not found at /root/.config/sops/age/keys.txt"
  exit 1
fi

# Ask user for zone location i.e. eu-frankfurt-1
echo "Enter the zone location (i.e. eu-frankfurt-1):"
read ZONE

# Ask user for region location i.e. vultrfra
echo "Enter the region location (i.e. vultrfra):"
read REGION

# Ask user for K3s token
echo "Enter the K3s token:"
read TOKEN

# Ask user for K3s server
echo "Enter the K3s server (i.e. https://myserver:6443):"
read K3S_SERVER

# Get Tailscale key from age encrypted file
TSKEY=$(cat /root/secrets/tailscale-key.age | age --decrypt -i /root/.config/sops/age/keys.txt)

# Get public IPv4 and IPv6 addresses
PUBLICV4=$(curl -s https://v4.ident.me)
PUBLICV6=$(curl -s https://v6.ident.me)


# Install our Kubernetes Distribution (K3s) with Tailscale
curl -sfL https://get.k3s.io | K3S_TOKEN=$TOKEN sh -s - agent \
    "-server=$K3S_SERVER" \
    "--node-name=$ZONE" \
    "--node-label=failure-domain.beta.kubernetes.io/zone=$ZONE" \
    "--node-label=failure-domain.beta.kubernetes.io/region=$REGION" \
    "--flannel-external-ip" \
    "--flannel-iface=tailscale0" \
    "--node-external-ip=$PUBLICV4" \
    "--node-external-ip=$PUBLICV6" \
    "--vpn-auth="name=tailscale,joinKey=$TSKEY""

# Install helm plugins
helm plugin install https://github.com/databus23/helm-diff
helm plugin install https://github.com/jkroepke/helm-secrets

exit 0
