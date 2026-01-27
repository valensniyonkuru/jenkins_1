pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // This pulls your code from GitHub
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                script {
                    // Replaces the manual 'docker build' command
                    sh "docker build -t my-ubuntu-website -f index.docker ."
                }
            }
        }

        stage('Test') {
            steps {
                // Basic check to see if the image exists
                sh "docker images | grep my-ubuntu-website"
            }
        }

        stage('Deploy Local') {
            steps {
                script {
                    // Remove old container if it exists, then run new one
                    sh "docker rm -f my-running-app || true"
                    sh "docker run -d -p 8081:80 --name my-ubuntu-website-container my-ubuntu-website"
                }
            }
        }
    }
}
