pipeline {
  agent any

  parameters {
    // Adding terraform worksapce parameter for selecting infrastructure environment
    string(name: 'WORKSPACE', defaultValue: 'development', description: 'Workspace/environment for deployment')
  }

  environment {
    AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    TF_IN_AUTOMATION      = "TRUE"
  }

  stages {
    stage('EC2 TF Init/Validate') {
      steps {
        // Using dir step for changing directory
        dir("ec2/") {
          sh 'terraform init -input=false'
          sh 'terraform validate'
        }
      }
    }
    stage('EC2 TF Plan') {
      steps {
        dir("ec2/") {
          script {
            try {
              sh "terraform workspace new ${params.WORKSPACE}"
            } catch (err) {
              sh "terraform workspace select ${params.WORKSPACE}"
            }
            sh "terraform plan -input=false -out ec2.tfplan;echo \$? > status"
            stash name: "ec2-plan", includes: "ec2.tfplan"
          }
        }
      }
    }

    stage('EC2 TF Approval') {
      steps {
        script {
          def apply = false
          try {
            input message: "Do you want to apply the plan?", ok: 'Apply Config'
          } catch (err) {
            apply = false
            currentBuild.result = 'UNSTABLE'
          }
          if(apply) {
            dir("ec2/") {
              sh "terraform apply -input=false ec2.tfplan"
            }
          }
        }
      }
    }
  }
}
