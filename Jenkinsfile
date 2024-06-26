pipeline {
    agent any

    parameters {
        string(name: 'environment', defaultValue: 'terraform', description: 'Workspace/environment file to use for deployment')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }

     environment {
         TF_VAR_access_key    = credentials('TF_VAR_access_key')
        TF_VAR_secret_key = credentials('TF_VAR_secret_key')
    }

    stages {


        stage('Plan') {

            steps {
                sh 'terraform init -upgrade'
                sh "terraform validate"
                sh "terraform plan"
            }
        }
        stage('Approval') {
           when {
               not {
                   equals expected: true, actual: params.autoApprove
               }
           }
           
           steps {
               script {
                    slackSend(
                    channel: '#test-jenkins-noti',
                    color: 'good', 
                    message: "Jenkins Build want it?"
                    )     
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan')]
               }
           }
       }

        stage('Apply') {
            steps {
                sh "terraform destroy -auto-approve"
                slackSend(
                channel: '#test-jenkins-noti',
                color: 'good', 
                message: "Jenkins Unbuild Successful"
) 
            }
        }
    }
}
