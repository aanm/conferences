#!/bin/bash

set -e

# Ensure no prompts from apt & co.
export DEBIAN_FRONTEND=noninteractive

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo --preserve-env=DEBIAN_FRONTEND apt-get update
sudo --preserve-env=DEBIAN_FRONTEND apt-get install -y docker.io

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

sudo swapoff -a

sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

cd /tmp
wget -nv https://get.helm.sh/helm-v3.3.0-linux-arm64.tar.gz
tar xzvf helm-v3.3.0-linux-arm64.tar.gz
sudo mv linux-arm64/helm /usr/local/bin/
