# Pet Clinic Application CI/CD Pipeline with Jenkins, ArgoCD, and Kubernetes
 
Petclinic is a Spring Boot application built using Maven. This project demonstrates a complete CI/CD pipeline for deploying a Java-based Pet Clinic application. The pipeline integrates Jenkins for Continuous Integration (CI) and ArgoCD for Continuous Deployment (CD), leveraging Minikube for Kubernetes-based application deployment.

![Main](https://github.com/user-attachments/assets/a55cfe64-a93f-47bd-99ec-69fe94228767)

### Key Features:
1. CI with Jenkins: Automates building, testing, and Docker image creation.
2. Static Code Analysis: Integrates SonarCloud to ensure code quality.
3. CD with ArgoCD: Deploys the application to a Kubernetes cluster using GitOps principles.
4. Kubernetes Deployment: Uses YAML manifests to define and manage application resources in Minikube.
5. Docker Integration: Builds and pushes Docker images to DockerHub for containerized deployment.

### Tech Stack:
1. Jenkins, Docker, SonarQube, ArgoCD
2. Kubernetes (Minikube), Maven
3. Azure Linux VM for hosting the CI/CD environment

## Execute the application locally and access it using your browser

#### Move to the directory and Checkout the repo

```
cd spring-petclinic
git clone https://github.com/pdonthala/spring-petclinic.git

```

You can either execute the artifact on your local machine (or) run it as a Docker container.

## Using Docker

#### Build the Docker Image

```
docker build -t spring-petclinic:v1 .
```

```
docker run -d -p 8080:8080 -t spring-petclinic:v1
```
![Dockerps](https://github.com/user-attachments/assets/dfafca7f-d3fe-4a5b-a0e0-8c848a4bb53a)


#### Access the application on `http://<ip-address>:8080`

![Page](https://github.com/user-attachments/assets/501d4a82-2e9f-40c5-9739-b7bcebb77e5b)


## Jenkins Pipeline for Java based application using Maven, SonarQube, Argo CD and Kubernetes

Here are the details to set up an end-to-end Jenkins pipeline for a Java application using SonarQube, Argo CD and Kubernetes:

Steps:

#### Configuring the Jenkins Environment
1. Install Jenkins and set it up with the necessary plugins like Git, Pipeline, and SonarQube for static code analysis.
2. Create credentials for secure access to external services (DockerHub, GitHub, Sonarqube ).

#### Create a new Jenkins pipeline:
1. In Jenkins, create a new pipeline job and configure it with the Git repository URL for the Java application.
2. Add a Jenkinsfile to the Git repository to define the pipeline stages.

   ![Jenkinsconfig](https://github.com/user-attachments/assets/adceab71-2e0b-4744-b030-fe7d74e31bd0)

   ![Jenkinsconfig2](https://github.com/user-attachments/assets/e067330b-7e46-4f9d-842c-033c0dc192a6)

#### Writing the Jenkinsfile with the following stages:
1. Build: Compiled the application using Maven. 

![Build](https://github.com/user-attachments/assets/06fb9c0d-5ce8-4d99-9ea1-ffe601fcde72)

2. Test: Ran unit tests to ensure code quality.

3. Static Analysis: Integrated SonarCloud to perform code analysis and enforce quality gates.

![Screenshot 2024-12-01 150547](https://github.com/user-attachments/assets/1cd4b5a4-5ebc-48dc-8210-9c2ab1a90a3c)

4. Docker Build & Push: Built a Docker image of the application and pushed it to DockerHub.

![Hub](https://github.com/user-attachments/assets/0d6fafe3-5dbc-476d-9ae6-13eaaf85552c)

Note: I used a docker image "pxdonthala/mavdocim:latest" as Jenkins agent instead of a VM. The image has maven, jdk, docker installed.


#### Setting Up the Application Environment
1. Use Minikube to create a local Kubernetes cluster for deployment testing.
![Screenshot 2024-12-01 214914](https://github.com/user-attachments/assets/da8f44ce-93df-4e76-8a0c-eefaed115d7d)

2. Deploy the application using ArgoCD.
![Screenshot 2024-12-01 210825](https://github.com/user-attachments/assets/6ffdb0a8-dd41-467c-9dc3-39698885e0c0)

References: 
1. To install minikube: https://minikube.sigs.k8s.io/docs/
2. To install kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
3. To install ArgoCD using Operator Lifecycle Manager: https://operatorhub.io/operator/argocd-operator



Note: To access the ArgoCD server, I added a NAT rule to forward traffic from my VM's external IP to the Minikube VM

![Screenshot 2024-12-02 012404](https://github.com/user-attachments/assets/4afdc728-a7f0-4d9b-9312-7c1039fde33e)

![Screenshot 2024-12-02 012619](https://github.com/user-attachments/assets/72f0aca1-d074-4a28-9ff4-eb12415339db)

![Screenshot 2024-12-02 023227](https://github.com/user-attachments/assets/c971c24c-1938-4e20-b118-e652073cc6b7)

![Screenshot 2024-12-02 020107](https://github.com/user-attachments/assets/92b24ea5-a5a9-4815-9d9a-804f2611fce8)

#### Testing & Final Deployment
1. Verified the end-to-end functionality of the CI pipeline by running successful builds, Docker image pushes, and Kubernetes deployments.



