def img

pipeline {
    environment {
        registry = "nitesh99sharma/emp-portal-project"
        registryCredential = 'DOCKERHUB'
        githubCredential = 'GitHub-Creds'
        dockerImage = ''
        scannerHome = tool 'sonar4.8'
    }

    agent any

    stages {
        stage('Checkout project') {
            steps {
                script {
                    // Checkout the project from GitHub
                    git branch: 'main',
                    url: 'https://github.com/fardeen-Git/Project.git'
                }
            }
        }

        stage('Installing packages') {
            steps {
                script {
                    // Install required Python packages
                    sh 'pip3 install -r requirements.txt'
                }
            }
        }

        stage('Static Code Checking') {
            steps {
                script {
                    // Run pylint on Python files and generate a report
                    sh 'find . -name \\*.py | xargs pylint -f parseable | tee pylint.log'
                    recordIssues(
                        tool: pyLint(pattern: 'pylint.log'),
                        unstableTotalHigh: 100
                    )
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonar') {
                        // Run SonarQube scanner for code analysis
                        sh '''${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=DevOps-Project \
                            -Dsonar.sources=.'''
                    }
                }
            }
        }

        stage("Testing with pytest") {
            steps {
                script {
                    withPythonEnv('python3') {
                        // Install required Python packages for testing
                        sh 'pip install pytest'
                        sh 'pip install flask_sqlalchemy'
                        // Run pytest for unit testing
                        sh 'pytest test_app.py'
                    }
                }
            }
        }

        stage ('Clean Up') {
            steps {
                // Stop and remove Docker containers
                sh returnStatus: true, script: 'docker stop $(docker ps -a | grep ${JOB_NAME} | awk \'{print $1}\')'
                sh returnStatus: true, script: 'docker rmi $(docker images | grep ${registry} | awk \'{print $3}\') --force'
                sh returnStatus: true, script: 'docker rm -f ${JOB_NAME}'
            }
        }

        stage('Build Image') {
            steps {
                script {
                    // Build Docker image with a unique tag
                    img = registry + ":${env.BUILD_ID}"
                    println("${img}")
                    dockerImage = docker.build("${img}")
                }
            }
        }

        stage('Push To DockerHub') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', registryCredential) {
                        // Push Docker image to DockerHub
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Deploy to containers') {
            steps {
                // Deploy Docker image to containers
                sh label: '', script: "docker run -d --name ${JOB_NAME} -p 5002:5000 ${img}"
            }
        }
}
}
