pipeline {
  agent {
    docker {
      image 'pxdonthala/mavdocim:latest'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'echo "Code has been checked out"'
      }
    }
    stage('Install Docker Compose') {
      steps {
        sh '''
          if ! command -v docker-compose &> /dev/null
          then
            echo "docker-compose could not be found, installing..."
            curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
          fi
        '''
      }
    }
    stage('Build and Test') {
      steps {
        sh 'mvn clean package'
      }
    }
    stage('Static Code Analysis') {
      environment {
        SONAR_URL = "https://ec2-54-161-37-108.compute-1.amazonaws.com:9000"
      }
      steps {
        withCredentials([string(credentialsId: 'sonar-pass', variable: 'SONAR_AUTH_TOKEN')]) {
          sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
        }
      }
    }
    stage('Pull and Push Docker Image') {
      environment {
        ORIGINAL_IMAGE = "pxdonthala/sprint-petclinic"
        YOUR_IMAGE = "badmancarteer/sprint-petclinic:${BUILD_NUMBER}"
        REGISTRY_CREDENTIALS = credentials('Docker-pass')
      }
      steps {
        script {
            sh 'docker pull ${ORIGINAL_IMAGE}'
            sh 'docker tag ${ORIGINAL_IMAGE} ${YOUR_IMAGE}'
            docker.withRegistry('https://index.docker.io/v1/', "Docker-pass") {
                sh 'docker push ${YOUR_IMAGE}'
            }
        }
      }
    }
    stage('Update Deployment File') {
      environment {
        GIT_REPO_NAME = "cicd-deployment-k8s-self-bootstrap"
        GIT_USER_NAME = "Olabode-Dev1"
      }
      steps {
        withCredentials([usernamePassword(credentialsId: 'Github-pass', usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_PASSWORD')]) {
            sh '''
                git config user.email "aderojuolabode001@gmail.com"
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
  }
