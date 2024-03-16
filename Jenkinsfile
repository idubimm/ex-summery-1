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
                    
                    if (runningContainers == "0") {
                        // The container is not running; check if it is stopped
                        def stoppedContainers = sh(script: "docker ps -a | grep postgers-idubi | wc -l", returnStdout: true).trim()
                        
                        if (stoppedContainers != "0") {
                            // The container exists but is stopped; start the container
                            sh "docker start postgers-idubi"
                    
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
                            
                        }
                    }
                }
            }
        }
          
        stage('Run Flask Application') {
            steps {
                script {
                    // Run the Flask application in no hup so it will not ber stuck
                    sh 'nohup python src/app.py > app_1.log&'
                }
            }
        }
        stage('check logs to see app running') {
            steps {
                script {
                    // chek logs of application execution
                    sh 'sleep 10'
                    sh 'echo "log for application run :"'
                    def success_app_py = sh(script: "cat app_1.log | grep 'Running on http://127.0.0.1:5000'| wc -l", returnStdout: true).trim()
                    int count_success = success_app_py.toInteger()
                    if (success_app_py != "0") {
                       sh 'echo "failed to load app"' 
                       
                       return false
                    } else {
                        echo "success loading the app"
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
        //             sh 'docker stop postgers-idubi'
        //             sh 'docker-compose -f ./docker-compose-image.yml up -d'
        //             }
        //         }
        //     }
    }
    post  {
            always  {  
                  script {              
                        sh "docker stop postgers-idubi"
                        sh 'pkill -f "python.*src/app.py"'
                        sh 'rm -fr *.log'
                        sh 'rm -fr *.log'
                        sh 'rm -fr nohup'
                  }
                }
            }
    }
