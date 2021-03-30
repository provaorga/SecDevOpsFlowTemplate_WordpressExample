pipeline {
  tools{
    terraform 'terraform'
  }
  agent any
  stages{
    stage('Provisioning VM on Proxmox with Terraform'){
      steps{
        withCredentials([usernamePassword(credentialsId: 'Proxmox', passwordVariable: 'PASSWORD', usernameVariable: 'USER')]) {
          //sh label: '', script: 'cd Provisioning; terraform init'
          //sh label: '', script: 'cd Provisioning; export PM_USER=${USER}; export PM_PASS=${PASSWORD}; terraform apply --auto-approve'
        }
      }
    }
    stage('Resource Configuration'){
      steps{
        withCredentials([usernamePassword(credentialsId: 'worker', passwordVariable: 'WORKER_PASS', usernameVariable: 'WORKER_USER'), usernamePassword(credentialsId: 'worker', passwordVariable: 'WORKER_SUDO_PASS', usernameVariable: ''), usernamePassword(credentialsId: 'master', passwordVariable: 'MASTER_PASS', usernameVariable: 'MASTER_USER'), usernamePassword(credentialsId: 'master', passwordVariable: 'MASTER_SUDO_PASS', usernameVariable: '')]){
         //ansiblePlaybook become: true, credentialsId: 'node', disableHostKeyChecking: true, installation: 'ansible', inventory: 'hosts', playbook: 'Resource Configuration/kubernetes/set_up_cluster.yml'
        }
      }
    }
    stage('Static Assessment Provisioned Environment'){
      steps{
        withCredentials([usernamePassword(credentialsId: 'worker', passwordVariable: 'WORKER_PASS', usernameVariable: 'WORKER_USER'), usernamePassword(credentialsId: 'worker', passwordVariable: 'WORKER_SUDO_PASS', usernameVariable: ''), usernamePassword(credentialsId: 'master', passwordVariable: 'MASTER_PASS', usernameVariable: 'MASTER_USER'), usernamePassword(credentialsId: 'master', passwordVariable: 'MASTER_SUDO_PASS', usernameVariable: '')]){
          ansiblePlaybook become: true, credentialsId: 'node', disableHostKeyChecking: true, installation: 'ansible', inventory: 'hosts', playbook: 'Static Security Assessment/oscap_assessment_playbook.yml'
          ansiblePlaybook become: true, credentialsId: 'node', disableHostKeyChecking: true, installation: 'ansible', inventory: 'hosts', playbook: 'Static Security Assessment/inspec_assessment_playbook.yml'
          
          withCredentials([usernamePassword(credentialsId: 'GIT', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
            sh 'git remote set-url origin "https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/provaorga/${JOB_NAME}.git"'
            sh 'git add Results/*'
            sh 'git commit -m "Add report File"'
            sh 'git push origin HEAD:main'
          }
        }
      }
    }
    stage('Deploy'){
      steps{
        script{
         load "version.txt"
         if(params.FRONT_END){
           env.WP=params.WP
         }
         kubernetesDeploy configs: 'Deploy/kubernetes/volumes.yaml', kubeConfig: [path: ''], kubeconfigId: 'kubconf', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']        
         kubernetesDeploy configs: 'Deploy/kubernetes/claims.yaml', kubeConfig: [path: ''], kubeconfigId: 'kubconf', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']        
         kubernetesDeploy configs: 'Deploy/kubernetes/deployments.yaml', kubeConfig: [path: ''], kubeconfigId: 'kubconf', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']        
        }
      }    
    }
  }
}
