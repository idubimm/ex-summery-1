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
        stage ('prepare dev environmant - create docer db with data '){
            steps{
                script {
                        // check that docker container not running ' if rinninng then skip' 
                        checkRunningPostgresContainers = "docker ps |grep postgers-idubi|wc |awk 'BEGIN {FS=" "}{print $1}"
                        def activePostgres = sh checkRunningPostgresContainers
                        if ["$activePostgres" -eq 0]{
                           checkStopedPostgresContainers = 'docker ps |grep postgers-idubi|wc |awk "BEGIN {FS=/" /"}{print $1}"'
                           def inActivePostgres = sh "docker ps -a|grep postgers-idubi|wc |awk 'BEGIN {FS=" "}{print $1}"
                                 if ["$inActivePostgres" -eq 0]{
                                // check that user logged in to docker , log in and run the image  
                                def loggedIn = sh(script: 'docker info | grep -i "Username"', returnStatus: true)
                                    if (loggedIn != 0) {
                                        // Not logged in, perform login using credentials stored in Jenkins
                                        withCredentials([usernamePassword(credentialsId: 'idubi_docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                                            sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                                        }
                                    }    
                                // run db image     
                                sh "docker run --name postgers-idubi -e POSTGRES_USER=idubi -e POSTGRES_PASSWORD=idubi -d -p 5432:5432 postgres "  
                            } 
                            //  if inactive > 0 we need only to start it 
                            else {
                                sh "docker start postgers-idubi"
                            }  
                }
            }
        }
        stage('Test PostgreSQL Connectivity') {
            steps {
                script {
                    // Adjust the waiting time as necessary for your container startup
                    sleep(30) // Wait for a few seconds to allow PostgreSQL to initialize
                     
                    sh "docker exec postgers-idubi pg_isready -h localhost"
                }
            }
        }        
        stage('Run Flask Application') {
            steps {
                script {
                    // Run the Flask application
                    // Ensure to replace `app.py` with the path to your Flask application entry point
                    // Also, adjust host and port as necessary
                    sh '. venv/bin/activate && python ./src/app.py'
                }
            }
        }
    }
        
}