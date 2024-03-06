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

# Get Tailscale key from age encrypted file
TSKEY=$(cat /root/secrets/tailscale-key.age | age --decrypt -i /root/.config/sops/age/keys.txt)

# Get public IPv4 and IPv6 addresses
PUBLICV4=$(curl -s https://v4.ident.me)
PUBLICV6=$(curl -s https://v6.ident.me)

# Install our Kubernetes Distribution (K3s) with Tailscale
curl -sfL https://get.k3s.io | sh -s - server \
    "--node-name=$ZONE" \
    "--flannel-ipv6-masq" \
    "--cluster-cidr=10.10.0.0/16,fd42::/48" \
    "--service-cidr=10.43.0.0/16,fd43::/112" \
    "--cluster-dns=10.43.0.10" \
    "--node-label=failure-domain.beta.kubernetes.io/zone=$ZONE" \
    "--node-label=failure-domain.beta.kubernetes.io/region=$REGION" \
    "--vpn-auth="name=tailscale,joinKey=$TSKEY"" \
    "--flannel-external-ip" \
    "--flannel-backend=wireguard-native" \
    "--flannel-iface=tailscale0" \
    "--disable=traefik" \
    "--disable=metrics-server" \
    "--disable=local-storage" \
    "--node-external-ip=$PUBLICV4" \
    "--node-external-ip=$PUBLICV6" \
    "--kube-controller-manager-arg=node-cidr-mask-size-ipv4=22" \
    "--kubelet-arg=max-pods=500" \
    "--tls-san=$PUBLICV4" \
    "--tls-san=$PUBLICV6"

# Install helm plugins
helm plugin install https://github.com/databus23/helm-diff
helm plugin install https://github.com/jkroepke/helm-secrets

TOKEN_FROM_FILE=$(cat /var/lib/rancher/k3s/server/node-token)
echo "The token in /var/lib/rancher/k3s/server/node-token is: $TOKEN_FROM_FILE"

exit 0
