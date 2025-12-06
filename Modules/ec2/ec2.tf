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
                curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
                sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
                curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
                sudo install minikube-linux-amd64 /usr/local/bin/minikube
                minikube start --driver=docker --force
                curl -sO http://192.168.1.4:8080/jnlpJars/agent.jar;java -jar agent.jar -url http://192.168.1.4:8080/ -secret e69a42aff15f55ff332881d0179371651f6c589a9cb66f42805b61ea0a90a0d0 -name "ec2-agent" -webSocket -workDir "/home/ubuntu/jenkins-home"
                EOF
}