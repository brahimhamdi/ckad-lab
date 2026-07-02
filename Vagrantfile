Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu64/noble64"
  config.vm.hostname = "ckad-vm"
  config.vm.network "private_network", ip: "192.168.56.220"
  config.vm.provider "virtualbox" do |vb|
    vb.name = "ckad-vm"
    vb.memory = "8192"
    vb.cpus = "4"
  end
  config.vm.provision "shell", inline: <<-SHELL
    apt --allow-unauthenticated update
    apt --allow-unauthenticated install -y bash-completion binutils
    echo 'colorscheme ron' >> ~/.vimrc
    echo 'set tabstop=2' >> ~/.vimrc
    echo 'set shiftwidth=2' >> ~/.vimrc
    echo 'set expandtab' >> ~/.vimrc
    echo 'source <(kubectl completion bash)' >> ~/.bashrc
    echo 'alias k=kubectl' >> ~/.bashrc
    echo 'alias c=clear' >> ~/.bashrc
    echo 'complete -F __start_kubectl k' >> ~/.bashrc
    sed -i '1s/^/force_color_prompt=yes\\n/' ~/.bashrc
    # modules & fonctionnalities
    #################################################
    sudo modprobe overlay
    sudo modprobe br_netfilter
    echo 'overlay' | sudo tee /etc/modules-load.d/containerd.conf
    echo 'br_netfilter' | sudo tee -a /etc/modules-load.d/containerd.conf
    echo 'net.bridge.bridge-nf-call-iptables = 1' | sudo tee /etc/sysctl.d/kubernetes.conf
    echo 'net.bridge.bridge-nf-call-ip6tables = 1' | sudo tee -a /etc/sysctl.d/kubernetes.conf
    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/kubernetes.conf
    sudo sysctl --system
    # Install & config containerd
    #################################################
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common tree
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt install -y containerd.io
    sudo containerd config default | sudo tee /etc/containerd/config.toml
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
    sudo systemctl restart containerd
    sudo crictl config runtime-endpoint unix:///run/containerd/containerd.sock
    # Install kubernetes
    ##############################################################
    sudo mkdir -p /etc/apt/keyrings
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    sudo apt update
    sudo apt install -y kubelet kubeadm kubectl
    echo "source <(kubectl completion bash)" >> ~/.bashrc
    # swap off
    sudo swapoff -a
    sudo sed -i '/swap/s/^/#/' /etc/fstab
    sudo rm -f /swap.img
    # Install Docker, openjdk, maven, ...
    sudo apt install -y git docker-ce openjdk-21-jdk maven mariadb-client
    sudo usermod -aG docker vagrant
    # Install Helm
    sudo snap install helm --classic
    echo "source <(helm completion bash)" >> ~/.bashrc
    # Install Kustomize
    wget "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"
    chmod +x install_kustomize.sh
    ./install_kustomize.sh
    sudo mv kustomize /usr/bin/
    # Init Cluster
    sudo kubeadm init --apiserver-advertise-address 192.168.56.220 --pod-network-cidr 10.32.0.0/12

    # Next commands issues !!!

    sudo mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown -R $(id -u):$(id -g) $HOME/.kube
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
    kubectl taint node ckad-vm node-role.kubernetes.io/control-plane:NoSchedule-

  SHELL
end
