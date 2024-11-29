pipeline {
    agent any
    environment {
        SONAR_HOME = tool "Sonar"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials" 
    }
    stages {
        stage("Code Checkout"){ 
            steps{
                checkout([$class: 'GitSCM', 
                          branches: [[name: '*/Fix/Readme.md']],
                          extensions: [
                              [$class: 'SparseCheckoutPaths', 
                               sparseCheckoutPaths: [
                                   [path: '.'],
                                   [path: '!docker/volumes/db/data/pgdata/']
                               ]
                              ]
                          ],
                          userRemoteConfigs: [
                              [url: 'https://github.com/DevOps-Playbbok/Capstone-Project.git', 
                               credentialsId: 'jenkins-git']
                          ]
                ])
            }
        }
        // stage("SonarQube Code Analysis") {
        //    steps {
        //        withSonarQubeEnv("Sonar") {
        //            sh "$SONAR_HOME/bin/sonar-scanner -Dsonar.projectName=Dify -Dsonar.projectKey=Dify"
        //        }
        //    }
       // }
        stage("Docker Build, Tag, and Push DEV") {
            steps {
                script {
                    def condition = false
                    
                    if (condition) {
                        def dockerImage = "amigo-nishant/dify"
                        def dockerTag = "latest"
                        
                        withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                            sh "docker build -t ${dockerImage}:${dockerTag} ."
                            sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                            sh "docker push ${dockerImage}:${dockerTag}"
                        }
                    } else { 
                         sh 'cd docker && docker compose up -d'
                       }
                }
            }
        }
        stage("Trivy File System Scan"){
            steps{
                sh "trivy fs --format  table -o trivy-fs-report.html ."
            }
        }
        stage("OWASP Dependency Check"){
            steps{
                echo "Skipping due to some dependency test cases are yet to be merged to main"
                // dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'dc'
                // dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage("PROD Deployment"){
            steps{
                sh "helm ls"
                sh "kubectl get nodes"
                sh "cd /var/lib/jenkins/workspace/Dify/Helm"
                sh "ls -l /var/lib/jenkins/workspace/Dify/Helm"
                sh "helm upgrade --install Dify /var/lib/jenkins/workspace/Dify/Helm --dry-run --debug"
                sh "helm upgrade --install Dify /var/lib/jenkins/workspace/Dify/Helm"
            }
        }
    }
}
