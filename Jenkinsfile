pipeline {
    agent any
    stages {
        stage ('Clone') {
            steps {
                sh 'git clone https://github.com/spring-projects/spring-petclinic.git'
            }
        }

        stage ('Build') {
            steps {
                dir("$WORKSPACE/spring-petclinic") {
                    //sh 'mvn dependency:resolve' // Resolve dependencies
                    sh 'mvn compile'
                }
            }
        }

        stage ('Test') {
            steps {
                dir("$WORKSPACE/spring-petclinic") {
                    sh 'mvn test'
                }
            }
        }

        stage ('Package') {
            steps {
                dir("$WORKSPACE/spring-petclinic") {
                    sh 'mvn package'
                    sh '''cat > Dockerfile << EOF
FROM alpine
RUN apk --no-cache add openjdk11
COPY target/spring-petclinic-2.6.0-SNAPSHOT.jar /app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EOF'''
                    script {
                        dockerImage = docker.build 'udid/spring-petclinic'
                    }
                }
                sh 'docker save udid/spring-petclinic > spring-petclinic.tar'
            }
        }

        stage ('Deploy') {
            steps {
                sh 'mkdir $WORKSPACE/jar'
                sh 'cd $WORKSPACE/jar'
                sh 'cp $WORKSPACE/spring-petclinic/target/spring-petclinic-2.6.0-SNAPSHOT.jar $WORKSPACE/jar'
                withCredentials([gitUsernamePassword(credentialsId: 'udidn_git', gitToolName: 'Default')]) {
                    sh 'git config --global user.name "udidn"'
                    sh 'git config --global user.email dahanehud@gmail.com'
                    sh 'git init'
                    sh 'git remote add origin https://github.com/udidn/spring-petclinic.git'
                    sh 'git pull origin main'
                    sh 'git add -f $WORKSPACE/jar/spring-petclinic-2.6.0-SNAPSHOT.jar'
                    sh 'git commit -m \"Added Jar file\"'
                    sh 'git branch -M main'
                    sh 'git push -u origin main'
                }
                script {
                    docker.withRegistry('https://registry-1.docker.io/v2/', 'udid_docker_hub') {
                        dockerImage.push()
                    }
                }
                
                rtUpload (
                    serverId: 'udid_artifactory',
                    spec: '''{
                          "files": [
                            {
                              "pattern": "spring-petclinic.tar",
                              "target": "udid_generic1"
                            }
                         ]
                    }'''
                )
            }
        }
    }
    post {
        always {
            cleanWs()
            dir("${env.WORKSPACE}@tmp") {
                deleteDir()
            }
            dir("${env.WORKSPACE}@script") {
                deleteDir()
            }
            dir("${env.WORKSPACE}@script@tmp") {
                deleteDir()
            }
        }
    }
}
