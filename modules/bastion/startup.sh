#!/bin/bash

sudo apt-get update -y
curl -LO https://dl.k8s.io/release/v1.28.3/bin/linux/amd64/kubectl
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
kubectl version --client

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version

sudo apt-get update -y
sudo apt-get install tinyproxy -y
