#!/bin/bash

# Requires age secret key to be present in /root/.config/sops/age/keys.txt

# Check /root/.config/sops/age/keys.txt exists
if [ ! -f /root/.config/sops/age/keys.txt ]; then
  echo "age secret key not found at /root/.config/sops/age/keys.txt"
  exit 1
fi

# Link age key to /root/infra/key.txt
ln -sf /root/.config/sops/age/keys.txt /root/infra/key.txt

git clone https://github.com/vojkovic/infra.git --depth 1 /root/infra
cd /root/infra

helmfile -f install-argocd.yaml sync

# Apply ArgoCD CRDs
kubectl apply -f ./argocd-applications/cert-manager-application.yaml
kubectl apply -f ./argocd-applications/cyberchef-application.yaml
kubectl apply -f ./argocd-applications/ingress-nginx-application.yaml
kubectl apply -f ./argocd-applications/kube-system-application.yaml
kubectl apply -f ./argocd-applications/searxng-application.yaml

exit 0
