resource "aws_instance" "ec2-instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install openjdk-21-jre -y
                sudo apt update -y
                sudo apt install docker.io -y
                sudo usermod -aG docker $USER
                newgrp docker
                sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
                curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
                sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
                curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
                sudo install minikube-linux-amd64 /usr/local/bin/minikube
                sudo apt update
                sudo apt install -y conntrack
                VERSION="v1.28.0"
                wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
                sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
                CNI_VERSION="v1.5.1"
                curl -LO https://github.com/containernetworking/plugins/releases/download/$${CNI_VERSION}/cni-plugins-linux-amd64-$${CNI_VERSION}.tgz
                sudo mkdir -p /opt/cni/bin
                sudo tar -C /opt/cni/bin -xzvf cni-plugins-linux-amd64-$${CNI_VERSION}.tgz
                sudo sed -i 's|bin_dir =.*|bin_dir = "/opt/cni/bin"|' /etc/containerd/config.toml
                sudo systemctl restart containerd
                sudo mkdir -p /etc/containerd
                sudo containerd config default | sudo tee /etc/containerd/config.toml
                sudo apt update
                sudo apt install -y \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg \
                lsb-release
                sudo mkdir -p /etc/apt/keyrings
                curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key \
                | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
                echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
                https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /" \
                | sudo tee /etc/apt/sources.list.d/kubernetes.list
                sudo apt update
                sudo apt install -y kubelet kubeadm kubectl
                sudo apt-mark hold kubelet kubeadm kubectl
                sudo systemctl enable kubelet
                sudo systemctl restart kubelet
                sudo minikube delete
                minikube update-context
                export KUBECONFIG=$HOME/.kube/config
                mkdir .kube
                sudo cp /root/.kube/config $HOME/.kube/config
                sudo chown $(id -u):$(id -g) $HOME/.kube/config
                mkdir -p $HOME/.minikube/profiles/minikube
                sudo cp /root/.minikube/ca.crt $HOME/.minikube/
                sudo cp /root/.minikube/profiles/minikube/client.crt $HOME/.minikube/profiles/minikube/
                sudo cp /root/.minikube/profiles/minikube/client.key $HOME/.minikube/profiles/minikube/
                sudo chown -R $(id -u):$(id -g) $HOME/.minikube
                chmod 600 $HOME/.minikube/profiles/minikube/client.key
                chmod 644 $HOME/.minikube/profiles/minikube/client.crt
                chmod 644 $HOME/.minikube/ca.crt
                $root='/root/.minikube'
                $home='/home/ubuntu/.minikube'
                sudo sed -i 's/$root/$home/g' $HOME/.kube/config
                sudo minikube start   --driver=none   --container-runtime=containerd   --memory=900   --force   --extra-config=kubelet.housekeeping-interval=10s   --extra-config=kubelet.image-gc-high-threshold=70   --extra-config=kubelet.image-gc-low-threshold=50
                curl -sO http://56.228.18.113:8080/jnlpJars/agent.jar
                java -jar agent.jar -url http://56.228.18.113:8080/ -secret 6805549cf92f0d25722770c30735727d6428f2ee4ee4187de954527d6cc7f513 -name agent -webSocket -workDir "/home/ubuntu"
                EOF
        key_name = var.key_name
        associate_public_ip_address = var.associate_public_ip_address
        security_groups = var.security_group_ids
}