terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.6.6"
    }
  }
}
provider "proxmox" {
    pm_api_url = "https://{IP_PROXMOX}/api2/json"
    pm_tls_insecure = "true"
}
