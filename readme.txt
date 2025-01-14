Note that if you are running jenkins as a container or vm, you need to have docker running on it, you  need maven as well, as specified by the jenkinsfile
Below is the command to run bind docker to the jenkins container while provisioning the jenkins container
docker run -d --name jenkins-server \
  -p 8080:8080 -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts


You also need to exec inside the container to install mvn as it will build the code, as specified in the jenkinsfile
