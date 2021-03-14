
variable "ip_list"{
  type  =  list
  default  =  ["192.168.6.114","192.168.6.115"]
}
variable "credentials_ciuser"{
  type  =  list
  default  =  ["master","worker"]
}
variable "credentials_cipassword"{
  type  =  list
  default  =  ["master","worker"]
}

resource "proxmox_vm_qemu" "proxmox_vm1" {
  count             = 2
  name              = "kub${count.index}"
  target_node       = "pve"
  clone             = "Deploy"
  desc              = <<-EOT
            user: ${var.credentials_ciuser[count.index]}
            password: ${var.credentials_cipassword[count.index]}
            root pass: ${var.credentials_cipassword[count.index]}
        EOT
  ciuser =  var.credentials_ciuser[count.index]
  cipassword =  var.credentials_cipassword[count.index]

  memory = 8192
  cores = "4"
  cpu = "kvm64"
  pool = "Tesi_Zagaria"
  define_connection_info = false
  hastate    =    "started"
  
  #Example  ipconfig0  = "ip=192.168.6.1${count.index+1}/24,gw=192.168.6.1" 
  ipconfig0  = "ip=${var.ip_list[count.index]}/24,gw=192.168.6.1"
  
disk {
  size         = "10000M"
  storage      = "nas_storage"
  type         = "scsi"
}
}

