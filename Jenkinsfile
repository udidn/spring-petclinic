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
                        docker.build 'udid/spring-petclinic'
                    }
                }
                sh 'docker save udid/spring-petclinic > spring-petclinic.tar'
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
