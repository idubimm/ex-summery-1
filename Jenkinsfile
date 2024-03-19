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
        stage('Manage Docker Container - prior condition posgres db need to be up') {
            steps {
                script {
                        withCredentials([usernamePassword(credentialsId: 'docker-idubi' , usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                                    sh '''#!/bin/bash
                                          chmod -R +x ./scripts
                                          source scripts/docker-utils.sh 
                                          # [1. container name]  [2. image name]  [3. docker run command if no container] [4,5 - docker credentials]
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
                                                    [1.flask app endpoint]   [2.#retries]  [3.interval secconds]
                            validate_flask_in_loop "http://127.0.0.1:5000"     5               1  
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
                        # since we are connecting to the db in docker compose with same port as the db , 
                        # and we open it for tests in host - we need to stop db (port is already allocated error)
                        #               [1.  container name ]
                        stop_container 'postgres-idubi'
                        #                   [1. domain]   [2. app name]     [3.dockerfile path]
                        build_docker_image   ''      'flask-crud'       './src/' 
                    '''
                    }
                }
            }            
        }
        stage('load docker image in docker compose - for testing inside container')       
        {
            steps {
                script{
                        //  we allready arive here after logged into docker so no need to 
                        //  load docker credentials agin
                        sh '''#!/bin/bash
                            source scripts/docker-utils.sh 
                            #                        [1. compose file path]         [2. docker build name]  [3. compose image prefix]
                            build_docker_compose  'src/docker-compose-image.yml'  'idubi/flask-crud:lts'    'flask-compose'
                        '''
                }
            }
        } 
        stage('test sanity for docker') 
        {
            steps {
                script {
                        sh '''#!/bin/bash
                            source scripts/test-flask-app.sh
                                                    [1.flask app endpoint]   [2.#retries]  [3.interval secconds]
                            validate_flask_in_loop "http://127.0.0.1:5000"     5               1  
                            source scripts/docker-utils.sh
                            stop_docker_compose 'src/docker-compose-image.yml'
                        '''                        
                }
            }
        }
    }
    post  {
            always  {  
                  script {    
                        sh '''#!/bin/bash
                            source scripts/docker-utils.sh  
                            stop_docker_compose 'src/docker-compose-image.yml'         
                            stop_container 'postgres-idubi'
                            stop_container 'flask-compose-web-app'
                            stop_container 'flask-compose-postgres-db'
                        '''
                  }
                }
            }
}     

       
        // stage('execute in kubernates'){
        //         steps{
        //             script{
        //                 sh 'kubectl apply -f ./kubernetes/'   
        //                 sh 'minikube service web-app --namespace flaskapp-python'
        //             }

        //         }
        //     }
    // }

     
