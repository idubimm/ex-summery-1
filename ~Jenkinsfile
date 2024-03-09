pipeline {
    agent any

    stages {
        stage('Clone Repository') {
            steps {
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/your/repository.git'
            }
        }

        stage('Build Python') {
            steps {
                sh 'python3 -m venv .venv'
                sh '. .venv/bin/activate && pip install -r requirements.txt'
            }
        } 

        stage('Build Docker Container') {
            environment {
                DOCKER_COMPOSE_VERSION = '1.27.4' // Update to the desired Docker Compose version
            }
            steps {
                sh "curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) -o docker-compose"
                sh 'chmod +x docker-compose'
                sh './docker-compose build'
            }
        }

        stage('Test Python Flask') {
            steps {
                sh '. .venv/bin/activate && python test.py'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                    sh "docker login -u ${DOCKER_HUB_USERNAME} -p ${DOCKER_HUB_PASSWORD}"
                    sh 'docker push yourusername/yourimage:latest'
                }
            }
        }
    }
}
