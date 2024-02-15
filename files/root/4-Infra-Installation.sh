#!/bin/bash

# Requires age secret key to be present in /root/.config/sops/age/keys.txt

# Check /root/.config/sops/age/keys.txt exists
if [ ! -f /root/.config/sops/age/keys.txt ]; then
  echo "age secret key not found at /root/.config/sops/age/keys.txt"
  exit 1
fi

git clone https://github.com/vojkovic/infra.git --depth 1 /root/infra
cd /root/infra

# Start helmfile
helmfile -f install-argocd.yaml apply

# Wait for ArgoCD to be ready
k3s kubectl apply -f ./argocd-application-set.yaml

exit 0
