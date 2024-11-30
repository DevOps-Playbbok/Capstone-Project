pipeline {
    agent any
    environment {
        SONAR_HOME = tool "Sonar"
    }
    parameters {
        choice(
            name: 'DEPLOY_ENV',
            choices: ['dev', 'prod'],
            description: 'Choose the environment to deploy: dev or prod'
        )
      }
    
    stages {
        stage("Code Checkout") {
            steps {
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
                            sh 'cd docker'
                        } else {
                            error "Docker directory not found. Ensure it is included in the repository and checkout."
                        }
                    }
                }
            }
        }
        //stage("SonarQube Code Analysis") {
        //steps {
        //withSonarQubeEnv("Sonar") {
          //  sh """
            //$SONAR_HOME/bin/sonar-scanner \
            //-Dsonar.projectName=dify \
            //-Dsonar.projectKey=dify \
            //-Dsonar.sources=. \
            //-Dsonar.exclusions=**/node_modules/**,**/*.test.js,**/vendor/**,**/*.md
            //"""
              //  }
            //}
        //}

        //stage("Sonar Quality Gate Scan"){
          //  steps{
            //    timeout(time: 2, unit: "MINUTES"){
              //      waitForQualityGate abortPipeline: false
                //}
            //}
        //}
        
        stage("Trivy File System Scan") {
            steps {
                sh "trivy fs --format table -o trivy-fs-report.html ."
            }
        }

        stage("OWASP Dependency Check") {
            steps {
                echo "Skipping due to some dependency test cases are yet to be merged to main"
            }
        }
        stage('Setup Namespaces') {
        steps {
            script {
            echo "Ensuring namespaces 'dev' and 'prod' exist..."

            // Define the namespaces to ensure
            def namespaces = ['dev', 'prod']

            namespaces.each { ns ->
                echo "Checking if namespace '${ns}' exists..."
                
                // Check if the namespace exists
                def nsExists = sh(script: "kubectl get namespace ${ns} --ignore-not-found=true", returnStatus: true) == 0

                if (nsExists) {
                    echo "Namespace '${ns}' already exists. Skipping creation."
                } else {
                    echo "Namespace '${ns}' does not exist. Creating it."
                    
                    // Create namespace YAML dynamically for missing namespace
                    def namespaceYaml = """
                    apiVersion: v1
                    kind: Namespace
                    metadata:
                      name: ${ns}
                    """
                    
                    // Save to a temporary file and apply the YAML
                    writeFile file: "${ns}-namespace.yaml", text: namespaceYaml
                    sh "kubectl apply -f ${ns}-namespace.yaml"
                    echo "Namespace '${ns}' created successfully."
                }
            }
        }
    }
}

        stage('Verify Namespaces') {
            steps {
                script {
                    echo "Listing all namespaces to verify creation:"
                    sh "kubectl get namespaces"
                }
            }
        }

        stage("DEV Deployment") {
            steps {
                script {
                    def namespace = params.DEPLOY_ENV
                    echo "Deploying to namespace: ${namespace}"
                    def helmPath = 'Helm/charts/dify'
                    def releaseName = 'dify'
                    def releaseExists = sh(script: "helm upgrade --install ${releaseName} ${helmPath} --dry-run --debug", returnStatus: true) == 0

                    if (releaseExists) {
                        sh "helm upgrade --install ${releaseName} ${helmPath}"
                    } else {
                        sh "helm repo add dify https://borispolonsky.github.io/dify-helm"
                        sh "helm repo update"
                        sh "helm upgrade --install release dify/dify -n ${namespace}"
                    }
                }
            }
        }
    }
}
