#!/bin/bash

set -e

kubeadm init

sudo -u ubuntu mkdir -p /home/ubuntu/.kube
sudo cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu -R /home/ubuntu/.kube/

export KUBECONFIG=/home/ubuntu/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/master-
