pipeline {
  tools{
    terraform 'terraform'
  }
  agent any
  stages{
    stage('Provisioning VM on Proxmox with Terraform'){
      steps{
        withCredentials([usernamePassword(credentialsId: 'Proxmox', passwordVariable: 'PASSWORD', usernameVariable: 'USER')]) {
          sh label: '', script: 'terraform init Provisioning'
          sh label: '', script: 'export PM_USER=${USER}; export PM_PASS=${PASSWORD}; terraform apply Provisioning --auto-approve'
        }
      }
    }
    stage('Resource Configuration'){
      steps{
        withCredentials([usernamePassword(credentialsId: 'worker', passwordVariable: 'WORKER_PASS', usernameVariable: 'WORKER_USER'), usernamePassword(credentialsId: 'worker', passwordVariable: 'WORKER_SUDO_PASS', usernameVariable: ''), usernamePassword(credentialsId: 'master', passwordVariable: 'MASTER_PASS', usernameVariable: 'MASTER_USER'), usernamePassword(credentialsId: 'master', passwordVariable: 'MASTER_SUDO_PASS', usernameVariable: '')]){
          ansiblePlaybook become: true, credentialsId: 'node', disableHostKeyChecking: true, installation: 'ansible', inventory: 'hosts', playbook: 'SResource COnfiguration/set_up_cluster.yml'
        }
      }
    }
    stage('Static Assessment Provisioned Environment'){
      steps{
        withCredentials([usernamePassword(credentialsId: 'worker', passwordVariable: 'WORKER_PASS', usernameVariable: 'WORKER_USER'), usernamePassword(credentialsId: 'worker', passwordVariable: 'WORKER_SUDO_PASS', usernameVariable: ''), usernamePassword(credentialsId: 'master', passwordVariable: 'MASTER_PASS', usernameVariable: 'MASTER_USER'), usernamePassword(credentialsId: 'master', passwordVariable: 'MASTER_SUDO_PASS', usernameVariable: '')]){
          ansiblePlaybook become: true, credentialsId: 'node', disableHostKeyChecking: true, installation: 'ansible', inventory: 'hosts', playbook: 'Static Security Assessment/oscap_assessment_kub.yml'
          ansiblePlaybook become: true, credentialsId: 'node', disableHostKeyChecking: true, installation: 'ansible', inventory: 'hosts', playbook: 'Static Security Assessment/inspec_assessment_kub.yml'
        }
      }
    }
    stage('Deploy'){
      steps{
        script{
         kubernetesDeploy configs: 'Deploy/namespaces.yaml, Deploy/deployments.yaml,Deployment/kaliDeployments.yml', kubeConfig: [path: ''], kubeconfigId: 'kubconf', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']        
        }
      }    
    }
  }
}
