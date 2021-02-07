pipeline {
  tools{
    terraform 'terraform'
  }
  agent any
  stages{
    stage('Provisioning VM on Proxmox with Terraform'){
      steps{
        withCredentials([usernamePassword(credentialsId: 'Proxmox', passwordVariable: 'PASSWORD', usernameVariable: 'USER')]) {
          sh 'echo Terraform Provisioning'
        }
      }
    }
    stage('Static Assessment Provisioned Environment'){
      steps{
        ansiblePlaybook become: true, credentialsId: 'node', disableHostKeyChecking: true, installation: 'ansible', inventory: '/etc/ansible/hosts', playbook: 'Ansible/oscap_assessment_kub.yml'
        ansiblePlaybook become: true, credentialsId: 'node', disableHostKeyChecking: true, installation: 'ansible', inventory: '/etc/ansible/hosts', playbook: 'Ansible/inspec_assessment_kub.yml'
      }
    }
    stage('Deploy'){
      steps{
        script{
          load "version.txt"
          if(params.FRONT_END){
            env.FRONT_END=params.FRONT_END
          }
         kubernetesDeploy configs: 'manifest/namespaces.yaml, manifest/deployments.yaml, manifest/kaliDeployments.yml', kubeConfig: [path: ''], kubeconfigId: 'kubconf', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']        
        }
      }    
    }
  }
}
