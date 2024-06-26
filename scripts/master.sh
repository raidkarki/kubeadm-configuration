#!/bin/bash
#
# Setup for Control Plane (Master) servers


set -euxo pipefail


sudo kubeadm config images list
sudo kubeadm config images pull


PUBLIC_IP_ACCESS="false"
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"


#kubectl drain $NODENAME --delete-emptydir-data --force --ignore-daemonsets
#kubeadm reset
if [[ "$PUBLIC_IP_ACCESS" == "false" ]]; then
    
    MASTER_PRIVATE_IP=$(ip addr show wlxe894f61e464a | awk '/inet / {print $2}' | cut -d/ -f1)
    sudo kubeadm init --pod-network-cidr="$POD_CIDR"

elif [[ "$PUBLIC_IP_ACCESS" == "true" ]]; then

    MASTER_PUBLIC_IP=$(curl ifconfig.me && echo "")
    sudo kubeadm init --control-plane-endpoint="$MASTER_PUBLIC_IP"  --pod-network-cidr="$POD_CIDR"

else
    echo "Error: MASTER_PUBLIC_IP has an invalid value: $PUBLIC_IP_ACCESS"
    exit 1
fi


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


kubectl taint nodes --all node-role.kubernetes.io/control-plane-


kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
