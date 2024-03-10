pipeline {
    agent any

    stages {
        stage('Setup Python Environment') {
            steps {
                script {
                    // Check if the virtual environment exists, if not create it
                    if (!fileExists("venv")) {
                        sh 'python -m venv venv'
                    }
                    // Install dependencies
                    sh '. venv/bin/activate && pip install -r ./src/requirements.txt'
                }
            }
        }

  stage('Manage Docker Container') {
            steps {
                script {
                    // Step 1: Check if the Docker container is up and running
                    def runningContainers = sh(script: "docker ps | grep postgers-idubi | wc -l", returnStdout: true).trim()
                    // this is a flag that we follow so if we start the container , we need to stop it later
                    containerWasStarted = false                    
                    if (runningContainers == "0") {
                        // The container is not running; check if it is stopped
                        def stoppedContainers = sh(script: "docker ps -a | grep postgers-idubi | wc -l", returnStdout: true).trim()
                        
                        if (stoppedContainers != "0") {
                            // The container exists but is stopped; start the container
                            sh "docker start postgers-idubi"
                            containerWasStarted = true
                        } else {
                            // The container does not exist; check Docker login
                            def loggedIn = sh(script: "docker info | grep -i 'Username' || true", returnStatus: true)
                            
                            if (loggedIn != 0) {
                                // Docker is not logged in; perform login using credentials stored in Jenkins
                                withCredentials([usernamePassword(credentialsId: 'idubi_docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                                    sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
                                }
                            }
                            
                            // Docker is logged in; run the new container
                            sh "docker run --name postgers-idubi -e POSTGRES_USER=idubi -e POSTGRES_PASSWORD=idubi -d -p 5432:5432 postgres"
                            containerWasStarted = true
                        }
                    }
                }
            }
        }

          
        stage('Run Flask Application') {
            steps {
                script {
                    // Run the Flask application
                    // Ensure to replace `app.py` with the path to your Flask application entry point
                    // Also, adjust host and port as necessary
                    sh 'nohup python src/app.py > app.log 2>&1'
                }
            }
        }

        stage('check logs to see app running') {
            steps {
                script {
                    // Run the Flask application
                    // Ensure to replace `app.py` with the path to your Flask application entry point
                    // Also, adjust host and port as necessary
                    sh 'nohup python src/app.py > app_1.log'
                    sh 'sleep 10'
                    def success_app_py = sh(script: "cat app_1.log | grep 'Running on http://127.0.0.1:5000'| wc -l", returnStdout: true).trim()
                    int count_success = success_app_py.toInteger()
                }
                post{
                    always{
                        steps{
                            script{
                                sh 'pkill -f "python.*app.py"'      
                            }
                        }
                    }
                }
            }
        }
    }
    post  {
            always  {
                steps{
                    script{
                        if (containerWasStarted) {
                            sh "docker stop postgers-idubi"
                        }  
                    }       
                }
            }
    }
}
