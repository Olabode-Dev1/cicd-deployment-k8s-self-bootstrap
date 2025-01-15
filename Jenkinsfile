pipeline {
  agent {
    docker {
      // Select a Docker image to run the below build, test on- Agent or VM
      image 'pxdonthala/mavdocim:latest'  // Image from the external repository
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock' // mount Docker socket to access the host's Docker daemon
    }
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
      environment {
        SONAR_URL = "http://40.118.247.151:9000"
      }
      steps {
        withCredentials([string(credentialsId: 'Sonar', variable: 'SONAR_AUTH_TOKEN')]) {
          sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
        }
      }
    }
    stage('Pull and Push Docker Image') {
    environment {
        ORIGINAL_IMAGE = "pxdonthala/sprint-petclinic"  // Original Docker image
        YOUR_IMAGE = "your-dockerhub-username/sprint-petclinic:${BUILD_NUMBER}"  // Your own Docker Hub image
        REGISTRY_CREDENTIALS = credentials('your-docker-cred-id')  // Your Docker Hub credentials
    }
    steps {
        script {
            // Pull the original image
            sh 'docker pull ${ORIGINAL_IMAGE}'

            // Tag the image with your own repository name
            sh 'docker tag ${ORIGINAL_IMAGE} ${YOUR_IMAGE}'

            // Push the image to your own Docker Hub repository
            docker.withRegistry('https://index.docker.io/v1/', "your-docker-cred-id") {
                sh 'docker push ${YOUR_IMAGE}'
            }
        }
    }
}

    stage('Update Deployment File') {
    environment {
        GIT_REPO_NAME = "spring-petclinic"
        GIT_USER_NAME = "your-username"
    }
    steps {
        withCredentials([usernamePassword(credentialsId: 'github-cred', usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_PASSWORD')]) {
            sh '''
                git config user.email "your-email@example.com"
                git config user.name "${GITHUB_USERNAME}"
                BUILD_NUMBER=${BUILD_NUMBER}
                sed -i "s/replaceImageTag/${BUILD_NUMBER}/g" k8s/deployment.yml
                git add k8s/deployment.yml
                git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                git push https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
            '''
        }
    }
}
