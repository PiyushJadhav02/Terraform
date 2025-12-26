pipeline {
    agent {label 'ec2-agent'}
    
    parameters{
        booleanParam(name:'autoApprove', defaultValue:false, description:'Automatically run apply after generating plan')
        choice(name: 'action', choices:['apply','destroy'], description:'Select the action to perform')
    }

    stages {
        stage('Terraform init'){
            steps{
                sh 'terraform init'
            }
        }
        stage('Plan'){
            steps{
                sh 'terraform plan -out tfplan'
            }
        }
        stage('Apply/Destroy'){
            steps{
                script{
                    if(params.action == "apply"){
                        sh 'terraform ${action} -input=false tfplan'
                    }
                    else if(params.action == "destroy"){
                        sh 'terraform ${action} --auto-approve'
                    }
                }
            }
        }
        stage('Git checkout k8s file'){
            steps{
                git branch: 'main', url:'https://github.com/PiyushJadhav02/Docker.git'
            }
        }
        stage('kubectl apply'){
            steps{
                sh 'kubectl apply -f deployment.yaml'
                sh 'kubectl get pods'
            }
        }
    }
}
