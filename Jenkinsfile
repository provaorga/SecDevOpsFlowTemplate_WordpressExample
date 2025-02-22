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
          //ansiblePlaybook become: true, credentialsId: 'node', disableHostKeyChecking: true, installation: 'ansible', inventory: 'hosts', playbook: 'Static Security Assessment/assessment_playbook.yml'
        }
      }
    }
    stage('Deploy'){
      steps{
        script{
         load "version.txt"
         if(params.WP){
           env.WP=params.WP
         }
         if(params.WB_DB){
           env.WP_DB=params.WP_DB
         }
         //kubernetesDeploy configs: 'Deploy/kubernetes/volumes.yaml', kubeConfig: [path: ''], kubeconfigId: 'kubconf', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']        
        // kubernetesDeploy configs: 'Deploy/kubernetes/claims.yaml', kubeConfig: [path: ''], kubeconfigId: 'kubconf', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']        
         //kubernetesDeploy configs: 'Deploy/kubernetes/deployments.yaml', kubeConfig: [path: ''], kubeconfigId: 'kubconf', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']        
        }
      }    
    }
  stage('DAST'){
    steps{
      withCredentials([usernamePassword(credentialsId: 'master', passwordVariable: 'MASTER_PASS', usernameVariable: 'MASTER_USER'), usernamePassword(credentialsId: 'KALI_CREDENTIALS', passwordVariable: 'KALI_PASS', usernameVariable: 'KALI_USER') ,string(credentialsId:'MASTER_IP', variable:'MASTER_IP'),, string(credentialsId:'KALI_IP', variable:'KALI_IP')]){
        script{
          def remote = [:]
          remote.name = "${MASTER_USER}"
          remote.host = "${MASTER_IP}"
          remote.user = "${MASTER_USER}"
          remote.password = "${MASTER_PASS}"
          remote.allowAnyHosts = true
          
          def kali = [:]
          kali.name = "${KALI_USER}"
          kali.host = "${KALI_IP}"
          kali.user = "${KALI_USER}"
          kali.password = "${KALI_PASS}"
          kali.allowAnyHosts = true
          
          sh 'echo "DAST in ZAP Container"'
          //kubernetesDeploy configs: 'DAST/zap.yaml', kubeConfig: [path: ''], kubeconfigId: 'provafile', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']        
          sh 'echo "DAST in Kali-Linux"'
          //sshPut remote: kali, from: 'DAST/kali_zap.sh', into: '.'
          //sshCommand remote: kali, command: "chmod +x kali_zap.sh && ./kali_zap.sh http://192.168.6.76:31381 /tmp/kali_zap_Report.html"
          
          //sshGet remote: kali, from: "/tmp/kali_zap_Report.html", into: "${WORKSPACE}/Results/${JOB_NAME}_kali_zap_report.html", override: true
          
          //kubernetesDeploy configs: 'DAST/zap.yaml', kubeConfig: [path: ''], deleteResource: 'true', kubeconfigId: 'provafile', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']        
         // sshGet remote: remote, from: "/tmp/zap/${JOB_NAME}.html", into: "${WORKSPACE}/Results/${JOB_NAME}.html", override: true
          
          sh 'echo WPScan in Kali-Linux'
          //sshPut remote: kali, from: 'DAST/kali_wpscan.sh', into: '.'
          //sshCommand remote: kali, command: "chmod +x kali_wpscan.sh && ./kali_wpscan.sh http://192.168.6.76:31381 /tmp/kali_wpscan_Report.txt"
          //sshGet remote: kali, from: "/tmp/kali_wpscan_Report.txt", into: "${WORKSPACE}/Results/${JOB_NAME}_kali_wpscan_report.txt", override: true
          /*
          withCredentials([usernamePassword(credentialsId: 'GIT', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
            sh 'git remote set-url origin "https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/provaorga/${JOB_NAME}.git"'
            sh 'git add Results/*'
            sh 'git commit -m "Add report File"'
            sh 'git push origin HEAD:main'
          }*/
        }
      }
    }
  }
}
}
