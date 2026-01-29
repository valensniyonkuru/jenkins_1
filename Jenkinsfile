pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Build Image') {
            steps { sh "docker build -t my-ubuntu-website ." }
        }
        stage('Push Image to Registry') {
            steps {
                script {
                    sh "docker tag my-ubuntu-website valensniyonkuru/my-ubuntu-website:latest"
                    withCredentials([usernamePassword(credentialsId: 'valENS118@', passwordVariable: 'DOCKER_PWD', usernameVariable: 'DOCKER_USER')]) {
                        sh "docker login -u $DOCKER_USER -p $DOCKER_PWD"
                        sh "docker push valensniyonkuru/my-ubuntu-website:latest"
                    }
                }
            }
        }
        stage('Deploy to AWS') {
            steps {
                script {
                    // Install Ansible (if needed) and Python for JSON parsing
                    sh "sudo apt-get update && sudo apt-get install -y ansible python3"

                    // Extract the instance IP from terraform.tfstate using Python
                    // This assumes terraform.tfstate is checked into the repo
                    def instanceIp = sh(script: "python3 -c \"import json; print(json.load(open('terraform.tfstate'))['outputs']['instance_public_ip']['value'])\"", returnStdout: true).trim()
                    
                    if (!instanceIp) {
                        error "Could not find instance_public_ip in terraform.tfstate"
                    }
                    
                    echo "Deploying to Instance IP: ${instanceIp}"

                    // Use SSH Key from Jenkins Credentials
                    // You must create a 'Secret file' or 'SSH Username with private key' credential with ID 'ec2-ssh-key'
                    withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                        // Run Ansible playbook
                        // Using -o StrictHostKeyChecking=no to avoid prompt on first connect
                        sh "ansible-playbook -i ${instanceIp}, deploy_app.yml --private-key \$SSH_KEY --ssh-extra-args='-o StrictHostKeyChecking=no'"
                    }
                }
            }
        }
    }
}
