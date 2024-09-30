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
    }
}
