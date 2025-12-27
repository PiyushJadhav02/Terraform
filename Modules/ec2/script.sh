#!/bin/bash
set -e

### VARIABLES ###
JENKINS_URL="http://13.51.64.135:8080"
AGENT_NAME="minikube-agent"
AGENT_SECRET="6805549cf92f0d25722770c30735727d6428f2ee4ee4187de954527d6cc7f513"
USER="ubuntu"
HOME_DIR="/home/ubuntu"

### BASIC SETUP ###
apt update -y
apt install -y openjdk-21-jre docker.io curl conntrack
sudo apt update
sudo apt install -y conntrack
VERSION="v1.28.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
CNI_VERSION="v1.5.1"
curl -LO https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz

### JENKINS AGENT ###
curl -sO http://13.51.64.135:8080/jnlpJars/agent.jar
java -jar agent.jar -url http://13.51.64.135:8080/ -secret 6805549cf92f0d25722770c30735727d6428f2ee4ee4187de954527d6cc7f513 -name agent -webSocket -workDir "/home/ubuntu" > agent.log 2>&1 &
echo "Jenkins agent started in background. Proceeding with other tasks..."

usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker

### CONTAINERD ###
apt install -y containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
systemctl restart containerd

### KUBECTL ###
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

### MINIKUBE ###
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube


### START MINIKUBE ###
sudo minikube start \
  --driver=none \
  --container-runtime=containerd \
  --memory=900 \
  --force

### FIX PERMISSIONS ###
sudo chown -R $USER $HOME/.minikube
chmod -R u+wrx $HOME/.minikube
mkdir -p $HOME_DIR/.kube $HOME_DIR/.minikube
cp -r /root/.kube/* $HOME_DIR/.kube/
cp -r /root/.minikube/* $HOME_DIR/.minikube/
chown -R ubuntu:ubuntu $HOME_DIR/.kube $HOME_DIR/.minikube