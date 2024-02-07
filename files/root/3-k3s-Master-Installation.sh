ZONE="eu-frankfurt-1"
REGION="vultrfra"

# Ask user for zone location i.e. eu-frankfurt-1
echo "Enter the zone location (i.e. eu-frankfurt-1):"
read ZONE

# Ask user for region location i.e. vultrfra
echo "Enter the region location (i.e. vultrfra):"
read REGION

# Get Tailscale key from age encrypted file
TSKEY=$(cat /root/secrets/tailscale-key.age | age --decrypt -i /root/age-key.txt)

# Get public IPv4 and IPv6 addresses
PUBLICV4=$(curl -s https://v4.ident.me)
PUBLICV6=$(curl -s https://v6.ident.me)

curl -sfL https://get.k3s.io | sh -s - server \
    "--flannel-ipv6-masq" \
    "--cluster-cidr=10.10.0.0/16,fd42::/48" \
    "--service-cidr=10.43.0.0/16,fd43::/112" \
    "--node-label=failure-domain.beta.kubernetes.io/zone=$ZONE" \
    "--node-label=failure-domain.beta.kubernetes.io/region=$REGION" \
    "--vpn-auth="name=tailscale,joinKey=$TSKEY"" \
    "--flannel-external-ip" \
    "--disable=traefik" \
    "--disable=metrics-server" \
    "--disable=coredns" \
    "--disable=local-storage" \
    "--node-external-ip=$PUBLICV4" \
    "--node-external-ip=$PUBLICV6" \
    "--kube-controller-manager-arg=node-cidr-mask-size-ipv4=22" \
    "--kubelet-arg=max-pods=500" \
    "--tls-san=$PUBLICV4" \
    "--tls-san=$PUBLICV6"

# Make tailscale node advertise as an exit node
tailscale up --advertise-exit-node --accept-routes --advertise-routes=10.10.0.0/22,fd42::/64