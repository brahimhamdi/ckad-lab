vagrant ssh -c 'sudo kubeadm token create --print-join-command' kube-control-plane > join-command
sed 's/kubeadm/sudo\ kubeadm/' join-command > join-command.sh
scp -o StrictHostKeyChecking=no -i ../.vagrant/machines/kube-node1/virtualbox/private_key join-command.sh vagrant@192.168.56.11:/tmp/
# scp -o StrictHostKeyChecking=no -i ../.vagrant/machines/kube-node2/virtualbox/private_key join-command.sh vagrant@192.168.56.12:/tmp/
vagrant ssh -c 'chmod a+x /tmp/join-command.sh' kube-node1
# vagrant ssh -c 'chmod a+x /tmp/join-command.sh' kube-node2
vagrant ssh -c 'sh /tmp/join-command.sh' kube-node1
# vagrant ssh -c 'sh /tmp/join-command.sh' kube-node2
rm -rf join-command*
