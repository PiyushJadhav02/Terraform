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
sudo -u ubuntu minikube start \
  --driver=none \
  --container-runtime=containerd \
  --memory=900 \
  --force

### FIX PERMISSIONS ###
mkdir -p $HOME_DIR/.kube $HOME_DIR/.minikube
cp -r /root/.kube/* $HOME_DIR/.kube/
cp -r /root/.minikube/* $HOME_DIR/.minikube/
chown -R ubuntu:ubuntu $HOME_DIR/.kube $HOME_DIR/.minikube

### JENKINS AGENT ###
mkdir -p /opt/jenkins
curl -sO $JENKINS_URL/jnlpJars/agent.jar
mv agent.jar /opt/jenkins/
chown -R ubuntu:ubuntu /opt/jenkins

cat <<EOF >/etc/systemd/system/jenkins-agent.service
[Unit]
Description=Jenkins Agent
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/jenkins
ExecStart=/usr/bin/java -jar /opt/jenkins/agent.jar \
  -url $JENKINS_URL \
  -secret $AGENT_SECRET \
  -name $AGENT_NAME \
  -workDir /opt/jenkins
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable jenkins-agent
systemctl start jenkins-agent
