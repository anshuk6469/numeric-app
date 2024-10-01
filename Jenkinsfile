pipeline {
    agent any

    tools {
        maven "maven_new"
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
              sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.projectName="numeric-application" -Dsonar.host.url=http://localhost:9000 -Dsonar.token=sqp_14503ef80336f7baa0068d1c116dd3b43bf0f279'
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
    }
}
