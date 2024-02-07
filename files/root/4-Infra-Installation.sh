#!/bin/bash

# Install infrastructure from git repository
# Requires age secret key to be present in /root/age-key.txt

# Check /root/age-key.txt exists
if [ ! -f /root/age-key.txt ]; then
  echo "age secret key not found at /root/age-key.txt"
  exit 1
fi

# Copy secret to ~/.config/sops/age/keys.txt
mkdir -p ~/.config/sops/age
cp /root/age-key.txt ~/.config/sops/age/keys.txt

git clone https://github.com/vojkovic/infra.git --depth 1 /root/infra
cd /root/infra

# Install helm plugins
helm plugin install https://github.com/databus23/helm-diff
helm plugin install https://github.com/jkroepke/helm-secrets

# Fix Error: Kubernetes cluster unreachable
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Start helmfile
helmfile -f install-argocd.yaml apply

# Wait for ArgoCD to be ready
k3s kubectl apply -f ./argocd-application-set.yaml

exit 0