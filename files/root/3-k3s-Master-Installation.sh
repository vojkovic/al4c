#!/bin/bash

# Install K3s server with tailscale
# Requires age secret key to be present in /root/.config/sops/age/keys.txt

# Check /root/.config/sops/age/keys.txt exists
if [ ! -f /root/.config/sops/age/keys.txt ]; then
  echo "age secret key not found at /root/.config/sops/age/keys.txt"
  exit 1
fi

# Set ZONE to the hostname of the machine
ZONE=$(cat /etc/hostname)

# Get Tailscale key from age encrypted file
TSKEY=$(cat /root/secrets/tailscale-key.age | age --decrypt -i /root/.config/sops/age/keys.txt)

# Get public IPv4 and IPv6 addresses
PUBLICV4=$(curl -s https://v4.ident.me)
PUBLICV6=$(curl -s https://v6.ident.me)

# Install our Kubernetes Distribution (K3s) with Tailscale
curl -sfL https://get.k3s.io | sh -s - server \
    "--node-name=$ZONE" \
    "--cluster-cidr=10.10.0.0/16,fd42::/48" \
    "--service-cidr=10.43.0.0/16,fd43::/112" \
    "--cluster-dns=10.43.0.10" \
    "--node-label=failure-domain.beta.kubernetes.io/zone=$ZONE" \
    "--vpn-auth="name=tailscale,joinKey=$TSKEY"" \
    "--flannel-ipv6-masq" \
    "--flannel-external-ip" \
    "--disable=traefik" \
    "--disable=metrics-server" \
    "--disable=local-storage" \
    "--node-external-ip=$PUBLICV4" \
    "--node-external-ip=$PUBLICV6" \
    "--kube-controller-manager-arg=node-cidr-mask-size-ipv4=22" \
    "--kubelet-arg=max-pods=500" \
    "--tls-san=$ZONE" \

# Install helm plugins
helm plugin install https://github.com/databus23/helm-diff
helm plugin install https://github.com/jkroepke/helm-secrets

TOKEN_FROM_FILE=$(cat /var/lib/rancher/k3s/server/node-token)
echo "The token in /var/lib/rancher/k3s/server/node-token is: $TOKEN_FROM_FILE"

exit 0
