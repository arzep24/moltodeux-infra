terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://192.168.1.100:8006/api2/json" # IP de Moltodeux
  pm_api_token_id = "root@pam!Terraform"             # ID del Token
  pm_api_token_secret = "f4bf46d3-c3d3-45ca-822c-201ab5ad9434"      # Secreto del Token
  pm_tls_insecure = true
}