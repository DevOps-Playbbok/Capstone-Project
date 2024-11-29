pipeline {
    agent any
    environment {
        SONAR_HOME = tool "Sonar"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials" 
    }
    stages {
        stage("Code Checkout"){ 
            steps{
                git(
                    url: "https://github.com/DevOps-Playbbok/Capstone-Project.git",
                    branch: "Fix/Readme.md",
                    credentialsId: "jenkins-git",
                    changelog: true,
                    poll: true
                )
            }
        }

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
                        // Check if the docker directory exists
                        if (fileExists('docker')) {
                            sh 'cd docker && docker compose up -d'
                        } else {
                            error "Docker directory not found. Ensure it is included in the repository and checkout."
                        }
                    }
                }
            }
        }
        
        stage("Trivy File System Scan") {
            steps {
                sh "trivy fs --format table -o trivy-fs-report.html ."
            }
        }
        
        stage("OWASP Dependency Check") {
            steps {
                echo "Skipping due to some dependency test cases are yet to be merged to main"
                // dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'dc'
                // dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        
        stage("PROD Deployment") {
            steps {
                script {
                    def helmPath = 'Helm'

                    // Validate if the Helm directory exists
                    if (fileExists(helmPath)) {
                        sh "helm ls"
                        sh "kubectl get nodes"
                        sh "cd ${helmPath}"
                        sh "ls -l ${helmPath}"
                        sh "helm upgrade --install dify ${helmPath} --dry-run --debug"
                        sh "helm upgrade --install dify ${helmPath}"
                    } else {
                        error "Helm directory not found. Ensure it is included in the repository and checkout."
                    }
                }
            }
        }
    }
}
