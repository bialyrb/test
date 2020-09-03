pipeline {
  agent any

  parameters {
    // Adding terraform worksapce parameter for selecting infrastructure environment
    string(name: 'TF_WORKSPACE', defaultValue: 'development', description: 'Workspace/environment for deployment')
    booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
  }

  environment {
  //  AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
  //  AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    PATH = "/usr/bin:$PATH"
    TF_IN_AUTOMATION      = "TRUE"
  }

  stages {
    stage('EC2 TF Init/Validate') {
      steps {
        // Using dir step for changing directory
        dir("${env.WORKSPACE}/ec2") {
          sh 'terraform init -input=false'
          sh 'terraform validate'
        }
      }
    }
    stage('EC2 TF Plan') {
      steps {
        dir("${env.WORKSPACE}/ec2") {
          script {
            try {
              sh "terraform workspace new ${params.TF_WORKSPACE}"
            } catch (err) {
              sh "terraform workspace select ${params.TF_WORKSPACE}"
            }
          }
          sh "terraform plan -input=false -out ec2.tfplan"
          sh "terraform show -no-color ec2.tfplan > ec2.tfplan.txt"
        }
      }
    }

    stage('EC2 TF Approval') {
      when {
        not {
          equals expected: true, actual: params.autoApprove
        }
      }

      steps {
        script {
          def plan = readFile 'ec2.tfplan.txt'
          input message: "Do you want to apply the plan?",
            parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
        }
      }
    }

    stage('EC2 TF Apply') {
      steps {
        dir("${env.WORKSPACE}/ec2") {
          sh "terraform apply -input=false ec2.tfplan"
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'ec2.tfplan.txt'
    }
  }
}
