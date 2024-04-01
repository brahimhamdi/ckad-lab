#!/bin/sh
vagrant ssh -c 'sudo kubeadm init --apiserver-advertise-address=192.168.56.10 --pod-network-cidr=10.32.0.0/12 --ignore-preflight-errors=NumCPU' kube-control-plane
vagrant ssh -c 'mkdir -p $HOME/.kube' kube-control-plane
vagrant ssh -c 'sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config' kube-control-plane
vagrant ssh -c 'sudo chown $(id -u):$(id -g) $HOME/.kube/config' kube-control-plane
# vagrant ssh -c 'kubectl apply -f weave-daemonset-k8s.yaml' kube-control-plane
# vagrant ssh -c 'kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml' kube-control-plane
vagrant ssh -c 'kubectl apply -f https://raw.githubusercontent.com/brahimhamdi/k8s-lab/master/calico.yaml' kube-control-plane

