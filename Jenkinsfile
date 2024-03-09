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
        stage('Run Flask Application') {
            steps {
                script {
                    // Run the Flask application
                    // Ensure to replace `app.py` with the path to your Flask application entry point
                    // Also, adjust host and port as necessary
                    sh '. $venv/bin/activate && python ./src/app.py'
                }
            }
        }
    }
        
}