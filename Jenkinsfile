pipeline {
    agent any

    tools {
        maven "maven_new"
    }
    environment {
        serviceName = "devsecops-svc"
        applicationURL="http://172.25.232.63"
        applicationURI="increment/99"
    }

    stages {
        stage('Build') {
            steps {
                git branch: 'main', url: 'https://github.com/anshuk6469/numeric-app.git'
                sh "mvn -DskipTests=true clean package"
            }
        }
        stage('Test') {
            steps {
                sh "mvn test"
            }
            post {
                always {
                    junit '**/target/surefire-reports/TEST-*.xml'
                    jacoco( execPattern: 'target/jacoco.exec' )
                }
            }
        }
        stage('PIT Mutation Testing') {
            steps {
              sh 'mvn org.pitest:pitest-maven:mutationCoverage'
            }
            post {
                always {
                   pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
                }
            }
        }
        stage('SAST SonrQube') {
            steps {
                withSonarQubeEnv('SonarQube') {
                  sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-application'
               }
              timeout(time: 2,unit: 'MINUTES') {
                script {
                    waitForQualityGate abortPipeline: true
                }
              }
            }
        }
        stage('Dependecies Vulnerability Scan') {
            steps {
              sh 'mvn dependency-check:check'
            }
            post {
                always {
                   dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
                }
            }
        }
        stage('Trivy Base Image Scan') {
            steps {
               sh 'bash trivy-docker-image-scan.sh'
            }
        }
        stage('Dockerfile Conf Scan') {
            steps {
               sh 'docker run --rm -v $(pwd):/project quay.io/anshuk6469/opaconftest test --policy docker-security.rego Dockerfile'
            }
        }
        stage('Docker Build and Push') {
            steps {
                withDockerRegistry(credentialsId: 'quay-cred', url: 'https://quay.io') {
                   sh 'docker build -t quay.io/anshuk6469/numeric-app:""$GIT_COMMIT"" .'
                   sh 'docker push quay.io/anshuk6469/numeric-app:""$GIT_COMMIT""'     
               }
            }
        }
        stage('K8s-Deploy') {
            steps {
               withKubeConfig(credentialsId: 'kubeconfig') {
                 sh "sed -i 's#replace#quay.io/anshuk6469/numeric-app:${GIT_COMMIT}#g' k8s_deploy_ser.yaml"
                 sh "kubectl apply -f k8s_deploy_ser.yaml"
               }
            }
        }
         stage('Integration Testing') {
            steps {
               withKubeConfig(credentialsId: 'kubeconfig') {
                 sh "bash integration-test.sh"
               }
            }
        }
         stage('OWASP ZAP DAST ') {
            steps {
               withKubeConfig(credentialsId: 'kubeconfig') {
                 sh "bash zap.sh"
               }
            }
            post {
               always {
                  publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'owasp-zap-report', reportFiles: 'zapreport.html', reportName: 'OWASP ZAP HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
    }
}
