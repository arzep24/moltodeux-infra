# --- VM 100: Titan-Hub (El Músculo) ---
# Host principal de Docker. Requiere recursos garantizados.
resource "proxmox_vm_qemu" "titan_hub" {
  name        = "titan-hub"
  target_node = "moltodeux"
  vmid        = 100
  clone       = "ubuntu-server-template" # Nombre de la plantilla en Proxmox
  cores       = 4
  sockets     = 1
  memory      = 8192
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # Disco de Sistema (El almacenamiento masivo se monta por NFS)
  disk {
    slot    = 0
    size    = "200G"
    type    = "scsi"
    storage = "local-lvm"
  }
}

# --- VM 111: OMV-Nuevo (El Almacén) ---
# OpenMediaVault. Gestiona los discos físicos pasados por Passthrough.
resource "proxmox_vm_qemu" "omv_nuevo" {
  name        = "omv-nuevo"
  target_node = "moltodeux"
  vmid        = 111
  clone       = "debian-server-template"
  cores       = 2
  memory      = 4096
  scsihw      = "virtio-scsi-pci"
  
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  disk {
    slot    = 0
    size    = "32G" # Solo sistema operativo
    type    = "scsi"
    storage = "local-lvm"
  }
}
# --- LXC 101: Cloudflare Tunnel ---
# Salida a internet segura sin abrir puertos en el router.
resource "proxmox_lxc" "cloudflare" {
  target_node  = "moltodeux"
  hostname     = "cloudflare-tunnel"
  vmid         = 101
  ostemplate   = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
  cores        = 1
  memory       = 512
  swap         = 512
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.1.250/24"
    gw     = "192.168.1.1"
  }
  
  rootfs {
    storage = "local-lvm"
    size    = "4G"
  }
}

# --- LXC 103: Adguard Home ---
# DNS Sinkhole. Bloquea publicidad a nivel de red.
resource "proxmox_lxc" "adguard" {
  target_node  = "moltodeux"
  hostname     = "adguard"
  vmid         = 103
  ostemplate   = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
  cores        = 1
  memory       = 512
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.1.210/24"
    gw     = "192.168.1.1"
  }
  
  rootfs {
    storage = "local-lvm"
    size    = "4G"
  }
}

# --- LXC 106: Tailscale ---
# VPN Mesh para acceso remoto administrativo.
resource "proxmox_lxc" "tailscale" {
  target_node  = "moltodeux"
  hostname     = "tailscale"
  vmid         = 106
  ostemplate   = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
  cores        = 1
  memory       = 512
  features {
    nesting = true # Necesario para crear interfaces de túnel
  }
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.1.251/24"
    gw     = "192.168.1.1"
  }
  
  rootfs {
    storage = "local-lvm"
    size    = "4G"
  }
}
# --- LXC 105: Gitea Server ---
# Repositorio de código (Git) self-hosted. El cerebro de IaC.
resource "proxmox_lxc" "gitea" {
  target_node  = "moltodeux"
  hostname     = "gitea-server"
  vmid         = 105
  ostemplate   = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
  cores        = 2
  memory       = 2048
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.1.115/24"
    gw     = "192.168.1.1"
  }
  
  rootfs {
    storage = "local-lvm"
    size    = "10G"
  }
}

# --- LXC 102: QBittorrent VPN ---
# Cliente Torrent con VPN (GlueTUN/Wireguard) integrada.
resource "proxmox_lxc" "qbittorrent" {
  target_node  = "moltodeux"
  hostname     = "qbitorrent-vpn"
  vmid         = 102
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  cores        = 2
  memory       = 2048
  features {
    nesting = true
  }
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.1.133/24"
    gw     = "192.168.1.1"
  }
  
  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }
}

# --- LXC 104: Monitor ---
# Stack de observabilidad (Uptime Kuma / Grafana).
resource "proxmox_lxc" "monitor" {
  target_node  = "moltodeux"
  hostname     = "monitor"
  vmid         = 104
  ostemplate   = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
  cores        = 1
  memory       = 1024
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.1.205/24"
    gw     = "192.168.1.1"
  }
  
  rootfs {
    storage = "local-lvm"
    size    = "4G"
  }
}

# --- LXC 107: Code Server ---
# VS Code accesible vía navegador.
resource "proxmox_lxc" "code_server" {
  target_node  = "moltodeux"
  hostname     = "code-server"
  vmid         = 107
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  cores        = 2
  memory       = 2048
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.1.212/24"
    gw     = "192.168.1.1"
  }
  
  rootfs {
    storage = "local-lvm"
    size    = "10G"
  }
}
# --- LXC 222: Minecraft Server ---
# Servidor de juegos Java. Requiere RAM dedicada.
resource "proxmox_lxc" "minecraft" {
  target_node  = "moltodeux"
  hostname     = "minecraft-server"
  vmid         = 222
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  cores        = 4
  memory       = 6144 # 6GB RAM
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.1.230/24"
    gw     = "192.168.1.1"
  }
  
  rootfs {
    storage = "local-lvm"
    size    = "32G"
  }
}