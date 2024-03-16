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
                    // Step 1: Check if the Docker postgres container is up and running
                    def runningContainers = sh(script: "docker ps | grep postgres-idubi | wc -l", returnStdout: true).trim()
                    // this is a flag that we follow so if we start the container , we need to stop it later
                    
                    if (runningContainers == "0") {
                        // The container is not running; check if it is stopped
                        sh 'echo "000 ---> postgres is offline" '
                        def stoppedContainers = sh(script: "docker ps -a | grep postgres-idubi | wc -l", returnStdout: true).trim()
                        
                        // postgres container available but stopped , need to start it 
                        if (stoppedContainers != "0") {
                            // The container exists but is stopped; start the container
                            sh 'echo "001 ---> postgres is offline starting stopped container " '
                            sh "docker start postgres-idubi"
                    
                        } else {
                            // The container does not exist; check Docker login
                            def loggedIn = sh(script: "docker info | grep -i 'Username' || true", returnStatus: true)
                            
                            if (loggedIn != 0) {
                                // Docker is not logged in; perform login using credentials stored in Jenkins
                                sh 'echo "002 ---> log-in to docker" '
                                withCredentials([usernamePassword(credentialsId: 'idubi_docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                                    sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
                                }
                            }
                            
                            // Docker is logged in; run the new container
                            sh 'echo "003 ---> creating postgres image" '
                            sh "docker run --name postgres-idubi -e POSTGRES_USER=idubi -e POSTGRES_PASSWORD=idubi -d -p 5432:5432 postgres"
                            
                        }
                    } else {
                        sh 'echo 004 ---> postgres is online '
                    }
                }
            }
        }
          
        stage('Run Flask Application') {
            steps {
                script {
                    // Run the Flask application in no hup so it will not ber stuck
                    // sh 'nohup python src/app.py>app_1.log&'
                    sh 'nohup python src/app.py>app_1.log&'
                }
            }
        }
        stage('check logs to see app running') {
            steps {
                script {
                    // chek logs of application execution
                    sh 'sleep 10'
                    sh 'echo "check application execution"'
                    def ping_response = sh(script: "curl -X POST http://localhost:5000/ping -H 'Content-Type: application/json' -d '{''message'':''ping''}'", returnStdout: true).trim()
                    sh "echo  '0005 ---> ping result = ' ${ping_response} "
                    if (ping_response == "pong") {
                        echo "success loading the app"
                    } else {
                       sh 'echo "failed to load app"' 
                       return false
                    }
                }
            }
        }
        // stage('build docker image for flask app and push to hub'){
        //             steps{
        //                 script{
        //                     sh 'docker build -t idubi/flask-app:lts ./src/'
        //                     def loggedIn = sh(script: "docker info | grep -i 'Username' || true", returnStatus: true)
        //                     if (loggedIn != 0) {
        //                         // Docker is not logged in; perform login using credentials stored in Jenkins
        //                         withCredentials([usernamePassword(credentialsId: 'idubi_docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
        //                             sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
        //                         }
        //                     }
        //                     sh 'docker push idubi/flask-app:lts'
        //                 }
        //             }
        //         }
        // stage('test with docker compose'){
        //         steps{
        //             script{
        //             sh 'docker stop postgres-idubi'
        //             sh 'docker-compose -f ./docker-compose-image.yml up -d'
        //             }
        //         }
        //     }
    }
    post  {
            always  {  
                  script {              
                        sh "mkdir ${env.BUILD_NUMBER}"
                        sh 'docker stop postgres-idubi'
                        sh 'pkill -f "python.*src/app.py"'
                        sh "mv *.log ${env.BUILD_NUMBER} "
                        sh "mv Jenkinsfile ${env.BUILD_NUMBER} "
                  }
                }
            }
    }
