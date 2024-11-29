pipeline {
    agent any
    environment {
        SONAR_HOME = tool "Sonar"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials" 
    }
    stages {
        stage("Code Checkout") { 
            steps {
                retry(3) {
                    cleanWs()  // Clean the workspace before checkout
                    
                    // Set permissions on the workspace to ensure Jenkins can access all files
                    sh '''
                    sudo chown -R $(whoami):$(whoami) . || true
                    sudo chmod -R 775 . || true
                    '''
                    
                    // Checkout the code with sparse paths
                    checkout([$class: 'GitSCM', 
                              branches: [[name: '*/Fix/Readme.md']],
                              extensions: [
                                  [$class: 'SparseCheckoutPaths', 
                                   sparseCheckoutPaths: [
                                       [path: '.'],
                                       [path: 'docker/'],  // Ensure docker directory is included
                                       [path: 'Helm/'],    // Include Helm directory
                                       [path: '!docker/volumes/db/data/pgdata/']  // Exclude pgdata
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
                        // Set permissions for Helm directory as well
                        sh '''
                        sudo chown -R $(whoami):$(whoami) ${helmPath} || true
                        sudo chmod -R 775 ${helmPath} || true
                        '''
                        
                        sh "helm ls"
                        sh "kubectl get nodes"
                        sh "cd ${helmPath}"
                        sh "ls -l ${helmPath}"
                        sh "helm upgrade --install Dify ${helmPath} --dry-run --debug"
                        sh "helm upgrade --install Dify ${helmPath}"
                    } else {
                        error "Helm directory not found. Ensure it is included in the repository and checkout."
                    }
                }
            }
        }
    }
}
