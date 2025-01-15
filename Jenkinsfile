pipeline {
    agent any  // Or use specific agent/docker configurations if needed
    environment {
        SONARQUBE_URL = 'http://<sonarqube-server-ip>:9000'  // Update with your SonarQube server URL
        SONARQUBE_TOKEN = credentials('SonarQube-Token')  // Replace with your SonarQube token credentials ID
    }
    stages {
        stage('Checkout') {
            steps {
                // Checkout the code
                sh 'echo "Code has been checked out"'
            }
        }
        stage('Build and Test') {
            steps {
                // List the files and then build the project to create a JAR
                sh 'ls -ltr'
                sh 'mvn clean package'
            }
        }
        stage('Static Code Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {  // Use the SonarQube server configured in Jenkins
                    // Run the SonarQube analysis with Maven
                    sh 'mvn sonar:sonar -Dsonar.login=${SONARQUBE_TOKEN} -Dsonar.host.url=${SONARQUBE_URL}'
                }
            }
        }
        stage('Build and Push Docker Image') {
            environment {
                DOCKER_IMAGE = "badmancarteer/clinic-cicd-deployment1:${BUILD_NUMBER}"
                REGISTRY_CREDENTIALS = credentials('Docker_password')  // Docker registry credentials
            }
            steps {
                script {
                    // Build the Docker image with the tag including the build number
                    sh "docker build -t ${DOCKER_IMAGE} ."
                    def dockerImage = docker.image("${DOCKER_IMAGE}")
                    
                    // Push the built Docker image to Docker Hub
                    docker.withRegistry('https://index.docker.io/v1/', "Docker_password") {
                        dockerImage.push()
                    }
                }
            }
        }
        stage('Update Deployment File') {
            environment {
                GIT_REPO_NAME = "cicd-deployment-k8s-self-bootstrap"
                GIT_USER_NAME = "olabode-Dev1"
            }
            steps {
                withCredentials([string(credentialsId: 'Github-password', variable: 'GITHUB_TOKEN')]) {
                    // Update the Kubernetes deployment YAML file with the new image tag
                    sh '''
                        git config user.email "aderojuolabode001@gmail.com"
                        git config user.name "olabode-Dev1"
                        BUILD_NUMBER=${BUILD_NUMBER}
                        sed -i "s/replaceImageTag/${BUILD_NUMBER}/g" k8s/deployment.yml
                        git add k8s/deployment.yml
                        git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                        git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                    '''
                }
            }
        }
    }
}
