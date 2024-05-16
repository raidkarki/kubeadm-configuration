#!/bin/bash
#
# Setup for Control Plane (Master) servers


set -euxo pipefail


sudo kubeadm config images list
sudo kubeadm config images pull


PUBLIC_IP_ACCESS="true"
NODENAME=$(hostname -s)
POD_CIDR="10.244.0.0/16"


#kubectl drain $NODENAME --delete-emptydir-data --force --ignore-daemonsets
#kubeadm reset
if [[ "$PUBLIC_IP_ACCESS" == "false" ]]; then
    
    MASTER_PRIVATE_IP=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
    sudo kubeadm init --apiserver-advertise-address="$MASTER_PRIVATE_IP" --apiserver-cert-extra-sans="$MASTER_PRIVATE_IP" --pod-network-cidr="$POD_CIDR" --cri-socket "unix:///var/run/containerd/containerd.sock" --node-name "$NODENAME" --ignore-preflight-errors Swap

elif [[ "$PUBLIC_IP_ACCESS" == "true" ]]; then

    MASTER_PUBLIC_IP=$(curl ifconfig.me && echo "")
    sudo kubeadm init --control-plane-endpoint= kube-master --apiserver-cert-extra-sans="$MASTER_PUBLIC_IP"   --pod-network-cidr="$POD_CIDR" --cri-socket "unix:///var/run/containerd/containerd.sock" --ignore-preflight-errors Swap

else
    echo "Error: MASTER_PUBLIC_IP has an invalid value: $PUBLIC_IP_ACCESS"
    exit 1
fi


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
