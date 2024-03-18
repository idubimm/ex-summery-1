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
                        withCredentials([usernamePassword(credentialsId: 'docker-idubi' , usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                                    sh '''#!/bin/bash
                                          chmod -R +x ./scripts
                                          source scripts/docker-utils.sh 
                                          prepare_docker_container "postgres-idubi" \
                                                  "postgres"  \
                                                  "docker run --name postgres-idubi -e POSTGRES_USER=idubi -e POSTGRES_PASSWORD=idubi -d -p 5432:5432 postgres" \
                                                  $DOCKER_USERNAME \
                                                  $DOCKER_PASSWORD 
                                       '''                                    
                                }
                }
            }
        }
        stage('build Flask Application') 
        {
            steps {
                script {
                        // Run the Flask application in no hup so it will not ber stuck
                        // sh 'nohup python src/app.py>app_1.log&'
                        sh 'nohup python src/app.py>app_1.log&'
                }
            }
        }
        stage('test sanity for application') 
        {
            steps {
                script {
                        sh '''#!/bin/bash
                        source scripts/test-flask-app.sh
                        validate_flask_in_loop "http://127.0.0.1:5000" 5 1  
                        # kill the application after test completed
                        pkill -f "python.*src/app.py"                     
                        '''
                }
            }
        }
        stage('build docker image ') 
        {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-idubi' , usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) 
                    {
                    sh '''#!/bin/bash
                    source scripts/docker-utils.sh 
                    build_docker_image 'flask-crud' 'idubi' './src/' 
                    '''
                    }
                }
            }            
        }
        stage('test sanity on created docker image with docker compose')       
        {
            steps {
                script{
                        //  we allready arive here after logged into docker so no need to 
                        //  load docker credentials agin
                        sh '''#!/bin/bash
                        source scripts/docker-utils.sh 
                        execute_docker_compose  './docker-compose-image.yml'  'idubi/flask-crud:lts' 'flasc-compose'
                        '''
                }
            }
        }
    }
}     

        
        // stage('build docker image for flask '){
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
        //                 sh 'docker stop postgres-idubi'
        //                 sh 'docker-compose -f ./docker-compose-image.yml up -d'
        //                 sh 'sleep 10'
        //                 sh 'docker start flascompose_web-app'
        //                 sh 'echo "check application execution"'
        //                 def ping_response = sh(script: "curl -X POST http://localhost:5000/ping -H 'Content-Type: application/json' -d '{''message'':''ping''}'", returnStdout: true).trim()
        //                 sh "echo  '0006 ---> ping result = ' ${ping_response} "
        //                 if (ping_response == "pong") {
        //                     echo "success loading the app"
        //                 } else {
        //                     echo "failed to load app" 
        //                     error('failed to get valid response from application')
        //                 }
        //             }

        //         }
        //     }    
        // stage('execute in kubernates'){
        //         steps{
        //             script{
        //                 sh 'kubectl apply -f ./kubernetes/'   
        //                 sh 'minikube service web-app --namespace flaskapp-python'
        //             }

        //         }
        //     }
    // }

    // post  {
    //         always  {  
    //               script {              
    //                     sh 'docker-compose -f ./docker-compose-image.yml down --remove-orphans'
    //                     def runningPostgres = sh(script: "docker ps | grep postgres-idubi | wc -l", returnStdout: true).trim()
    //                     if (runningPostgres == "1") {
    //                        sh 'docker stop postgres-idubi'
    //                     }
    //                     def runningComposeWebApp = sh(script: "docker ps | grep flascompose_web-app | wc -l", returnStdout: true).trim()
    //                     if (runningComposeWebApp == "1") {
    //                        sh 'docker stop flascompose_web-app'
    //                     }
    //                     def runningComposePostgres = sh(script: "docker ps | grep flascompose_postgres-db | wc -l", returnStdout: true).trim()
    //                     if (runningComposePostgres == "1") {
    //                        sh 'docker stop flascompose_postgres-db'
    //                     }
    //               }
    //             }
    //         }
    // }
