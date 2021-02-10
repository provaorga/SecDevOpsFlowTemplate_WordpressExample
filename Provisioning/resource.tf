
variable "ip_list"{
  type  =  list
  default  =  ["{IP1}","{IP2}"]
}

resource "proxmox_vm_qemu" "proxmox_vm1" {
  count             = {VM_COUNT}
  name              = "{VM_NAME}${count.index}"
  target_node       = "pve"
  clone             = "{VM_TEMPLATE_NAME}"
  desc              = <<-EOT
            user: deploy
            password: deploy
            root pass: deploy
        EOT
  memory = {MEMORY_IN_MB}
  cores = "{CORE}"
  cpu = "kvm64"
  pool = "Tesi_Zagaria"
  define_connection_info = false
  hastate    =    "started"
  
  #Example  ipconfig0  = "ip=192.168.6.1${count.index+1}/24,gw=192.168.6.1" 
  ipconfig0  = "ip=${var.ip_list[count.index]}/24,gw={GATEWAY}"
  
disk {
  size         = "{SIZE_IN_MB}"
  storage      = "nas_storage"
  type         = "scsi"
}
}

