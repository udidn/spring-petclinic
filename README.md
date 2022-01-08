# Spring PetClinic Exercise

Sprint PetClinic is a sample Spring application buit using Maven.

## How to Use this Readme File

1. Exercise Walkthrough:
Explanation of the work done as part of the exercise.
2. How to Run the Project:
Instructions on different way to run the project.

## Exercise Walkthrough

### Getting Started

1. Since I didn't work with Git before, I walked-thtough the following short getting started (including installing git, and GitHub account creation)

2. I read basics about Maven

### Launched Spring PetClinic Locally

1. Cloned the Spring PetClinic repository to my local WSL2 Ubuntu 20.04:
git clone https://github.com/spring-projects/spring-petclinic.git

2. Compiled and packaged it using ```./mvnw package```

As I understand, this command builds Maven project without having Maven installed.

3. Started Spring PetClinic using ```java -jar target/*.jar```, and sucessfully accessed it on http://localhost:8080

### Installed Maven and Packaged Spring PetClinic with mvn

1. Used ```mvn compile``` to compile the source code
2. Used ```mvn test``` to compile and run the tests
3. Used ```mvn package``` to create the JAR
4. Found that I can use ```mvn dependency:resolve``` to resolve dependencies first, then run the above
5. Started Spring PetClinic using ```java -jar target/*.jar```, and sucessfully accessed it on http://localhost:8080

### Spring PetClinic Docker Image

1. Created Dockerfile, tried making it as smallest image as possible. Ended up with the following:

```bash
FROM alpine
RUN apk --no-cache add openjdk11
COPY target/spring-petclinic-2.6.0-SNAPSHOT.jar /app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
```
If I use OpenJDK as base image, it becomes larger, that's why I use Alpine, and then install openjdk11.

2. Created container from the container image, and verified that I can access Spring PetClinic over http:/localhost:8080

3. Created TAR file to be used as runnable image using ```docker save```, verified that I can load the image using ```docker load```, created container from it, and verified that I can access Spring PetClinic over http:/localhost:8080

### Jenkins Pipeline Script

1. Created Jenkins Dockerfile, built image, launched conatiner.
I used the following Dockerfile:

```bash
FROM jenkins/jenkins:2.319.1-jdk11
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
RUN apt-get install -y maven
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean:1.25.2 docker-workflow:1.26"
```

2. Installed suggested plugins

3. I started writing declarative pipline (using the Jenkins UI - used "Definition" as "Pipeline script"), step-by-step, and I launched a build after every step:

    1. Stage "Clone", to clone the Sprint PetClinic repository from GitHub
    2. Stage "Build", including: resolving Maven dependencies and compiling
    3. Stage "Test", to compile and run the tests
    4. Stage "Package", including: packaging the compiled code to JAR file using Maven, building Docker image, and saving the Docker image as TAR file
    5. Stage "Push", including: pushing the Docker image to Docker Hub, pushing the Docker image TAR file to JFrog Artiactory Generic Repository, and deploying to JFrog Artifactory Maven repository

Notes:

1. As part of step 3.iv above, I ran into an issue using Docker (to build the Docker image) inside the Jenkins Docker container (issue accessing Docker API).
Eventually, I decided to remove the Jenkins container and install Jenkins locally on my WSL2 Ubuntu 20.04.

2. Also as part of step 3.iv above, I wanted to try and push the JAR to the GitHub repository.
I understand that it's not a text file and therefore, can't be version-controlled, but I wanted to provide additional way for the users to pull run the project (by cloning the repository, building Docker image from the Dockerfile - which includes copying the JAR - and launching a container).
I ran into multiple issues, among them:

    1. I couldn't push the JAR because the remote contained content that I don't have locally
    2. I then realized I need to pull, which solved the issue
    3. However, I then ran into another, when I tried pushing the JAR file once again to the repository, the pull operation failed


3. I had JFrog Artifactory already installed on my WSL2 Ubuntu 20.04, as part of self-learning from few weeks ago.
I only had to install the Artifactory Jenkins plugin and configure it.

4. At this point, since Jenkins was installed locally and listening on port 8080, everytime I had to verify that the Spring PetClinic application, I exposed it on a port different than 8080 (when launching the conatiner)

5. Throughout writing the declarative pipeline, at some point, I pushed the Jenkinsfile to GitHub, switched the "Definition" from "Pipline script" to "Pipeline script from SCM", and verified I can run a build.
When I had to modify the Jenkinsfile, I switched the "Definition" back to "Pipeline script", rewrote, test running a build, then updated the GitHub repository and swiched back the "Definition" to "Pipeline script from SCM".

6. As part of step 3.v above, when I first experimented with the Maven part of the Jenkins Artifactory pipeline plugin, I used both "rtMavenResolver" and "rtMavenDeployer", and referenced them in "rtMavenRun".
The build failed, and as part of observing the console logs, I saw that Maven tries resolving the dependencies in pom.xml, from JFrog Artifactory.
That's when I realized that "rtMavenResolver" is used to instruct Maven to resolve all dependencies in pom.xml, from JFrog Artifactory, and since they're not there, it fails.
I removed "rtMavenResolver" (and its reference in "rtMavenRun"), and the build succeeded.

### Final Steps

1. Pushed the Spring PetClinic Dockerfile to GitHub
2. Verified that I can run the project in the following as if I was a user:
I pulled the Spring PetClinic Docker Image from Docker Hub using a Docker client that isn't authenticated with my Docker Hub account, launched a conatiner, and verified that I can successfully access Spring PetClinic over "http://localhost:8080"

3. Verified that I can access the GitHub repository using web browser, when I'm signed-out

4. Wrote this Readme file and pushed it to GitHub

## How to Run the Project

### Pull from Docker Hub

```bash
docker run --name spring-petclinic -d -p 8080:8080 udid/spring-petclinic
```

After a few seconds, you should be able to access Spring PetClinic over "http://localhost:8080".
