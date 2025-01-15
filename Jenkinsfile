pipeline {
    agent any  // Or use specific agent/docker configurations if needed
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
        // stage('Static Code Analysis') {
        // Uncomment this stage if you wish to run SonarQube analysis
        //     environment {
        //         SONAR_URL = "http://40.118.247.151:9000"
        //     }
        //     steps {
        //         withCredentials([string(credentialsId: 'Sonar', variable: 'SONAR_AUTH_TOKEN')]) {
        //             sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
        //         }
        //     }
        // }
        stage('Build and Push Docker Image') {
            environment {
                DOCKER_IMAGE = "badmancarteer/clinic-cicd-deployment1:${BUILD_NUMBER}"
                REGISTRY_CREDENTIALS = credentials('Docker-pass')  // Docker registry credentials
            }
            steps {
                script {
                    // Build the Docker image with the tag including the build number
                    sh "docker build -t ${DOCKER_IMAGE} ."
                    def dockerImage = docker.image("${DOCKER_IMAGE}")
                    
                    // Push the built Docker image to Docker Hub
                    docker.withRegistry('https://index.docker.io/v1/', "Docker-pass") {
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
                withCredentials([string(credentialsId: 'Github-pass', variable: 'GITHUB_TOKEN')]) {
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
