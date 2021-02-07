terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.6.6"
    }
  }
}
provider "proxmox" {
    pm_api_url = "https://10.224.16.41:8006/api2/json"
    pm_tls_insecure = "true"
    pm_log_enable = "true"
    pm_log_levels = {
     _default = "debug"
     _capturelog = ""
    }
}
resource "proxmox_vm_qemu" "proxmox_vm" {
  count             = 1
  name              = "tf-vm"
  target_node       = "pve"
  clone             = "Template"
  memory = 8192
  cores = "4"
  cpu = "kvm64"
  full_clone = "false"
  pool = "Tesi_Zagaria"
  define_connection_info = false
  

disk {
  backup       = false
  cache        = "none"
  iothread     = false
  replicate    = false
  size         = "22732M"
  slot         = 0
  ssd          = false
  storage      = "nas_storage"
  type         = "scsi"
}
 }
