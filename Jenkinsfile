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
                        sh 'chmod -R +x ./scripts'
                        sh './scripts/docker-utils.sh'
                        prepare_docker_container 'postgres-idubi'
                }
            }
        }
    }
    }
          
        // stage('buil Flask Application') {
        //     steps {
        //         script {
        //             // Run the Flask application in no hup so it will not ber stuck
        //             // sh 'nohup python src/app.py>app_1.log&'
        //             sh 'nohup python src/app.py>app_1.log&'
        //         }
        //     }
        // }
        // stage('check logs to see app running') {
        //     steps {
        //         script {
        //             // chek logs of application execution
        //             sh 'sleep 10'
        //             sh 'echo "check application execution"'
        //             def ping_response = sh(script: "curl -X POST http://localhost:5000/ping -H 'Content-Type: application/json' -d '{''message'':''ping''}'", returnStdout: true).trim()
        //             sh "echo  '0005 ---> ping result = ' ${ping_response} "
        //             if (ping_response == "pong") {
        //                 echo "success loading the app"
        //                 sh 'pkill -f "python.*src/app.py"'
        //                 echo "force stopp running application"
        //             } else {
        //                echo "failed to load app" 
        //                error('failed to get valid response from application')
        //                return false
        //             }
        //         }
        //     }
        // }
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
