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
                    sh 'mvn dependency:resolve'
                    sh 'mvn dependency:resolve-plugins'
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

                    // Package, build Docker image and save it to TAR file
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

        stage ('Push') {
            steps {

                // Push Docker image to Docker Hub
                script {
                    docker.withRegistry('https://registry-1.docker.io/v2/', 'udid_docker_hub') {
                        dockerImage.push()
                    }
                }

                //Push Docker image TAR to JFrog Artifactory Generic Repository
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
                
                rtMavenResolver (
                    id: 'resolver-unique-id',
                    serverId: 'udid_artifactory',
                    releaseRepo: 'udid_maven',
                    snapshotRepo: 'udid_maven'
                )

                rtMavenDeployer (
                    id: 'deployer-unique-id',
                    serverId: 'udid_artifactory',
                    releaseRepo: 'udid_maven',
                    snapshotRepo: 'udid_maven',
                )

                rtMavenRun (
                    // Tool name from Jenkins configuration.
                    tool: udid_maven,
                    // Set to true if you'd like the build to use the Maven Wrapper.
                    useWrapper: true,
                    pom: '$WORKSPACE/spring-petclinic/pom.xml',
                    goals: 'clean install',
                    // Maven options.
                    opts: '-Xms1024m -Xmx4096m',
                    resolverId: 'resolver-unique-id',
                    deployerId: 'deployer-unique-id',
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
