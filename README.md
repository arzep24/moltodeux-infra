# Moltodeux Infrastructure
Este repositorio contiene el código fuente completo para la gestión del Homelab `Moltodeux`. Implementa una filosofía de **Infraestructura como Código (IaC)** dividida en tres capas lógicas para garantizar un sistema robusto, reproducible y con mantenimiento automatizado.

## Requisitos Previos
- Control Node: WSL (Windows Subsystem for Linux) o Linux Nativo.
- Herramientas: ansible, terraform, git, sshpass.
- Acceso: Llaves SSH públicas distribuidas en todos los nodos.
- Proxmox API: Token generado para Terraform.

## 🏛️ Arquitectura del Sistema

El proyecto sigue una estrategia de 3 capas:
| Capa | Tecnología | Función | Estado |
| :--- | :--- | :--- | :--- |
| **1. Infraestructura** | **Terraform** | **"El Constructor"**: Define y crea las VMs y Contenedores LXC en Proxmox. | 🟡 *DRP (Plan de Recuperación)* |
| **2. Configuración** | **Ansible** | **"El Configurador"**: Instala SO, usuarios, seguridad y dependencias (Docker). | 🟢 *Activo / Automatizado* |
| **3. Aplicaciones** | **Docker** | **"El Servicio"**: Despliegue de aplicaciones (Plex, *Arr, Gitea) en contenedores. | 🟠 *Híbrido (En migración)* |

---

## 📂 Estructura del Repositorio

```text
moltodeux-infra/
├── terraform/              # CAPA 1: Definición de recursos (VMs/LXC)
│   ├── main.tf             # Declaración de los 11 nodos
│   └── provider.tf         # Conexión con Proxmox API
│
├── inventory/              # CAPA 2: Inventario de Ansible
│   ├── hosts.ini           # Mapa de IPs y Grupos
│   └── group_vars/         # Variables (ej. Protección de discos Docker)
│
├── playbooks/              # CAPA 2: Lógica de orquestación
│   └── site.yml            # Playbook Maestro
│
├── roles/                  # CAPA 2: Habilidades modulares
│   ├── common/             # Base (Timezone, Utils, QEMU Agent)
│   ├── system_maintenance/ # Actualizaciones Desatendidas (Auto-patching)
│   ├── proxmox_host/       # Configuración del Bare Metal
│   └── docker_stack/       # Instalación Docker + Systemd Override
│
└── stacks/                 # CAPA 3: Definiciones de Docker Compose (Futuro)
```

## Capa 1: Infraestructura (Terraform)
Código para aprovisionar los recursos en el hipervisor Proxmox.
Objetivo: Recuperación ante desastres (Disaster Recovery). Permite reconstruir los 11 nodos desde cero en caso de fallo total del hardware.
Ubicación: `./terraform/`

Uso básico:
```Bash
cd terraform
# Inicializar plugins
terraform init
# Ver qué cambios haría (Plan)
terraform plan
# Aplicar cambios (Crear/Destruir máquinas)
terraform apply
```
⚠️ Nota: No ejecutar apply sobre la infraestructura viva actual sin revisar el plan, ya que podría intentar recrear máquinas existentes.

## Capa 2: Configuración (Ansible)
Gestión de configuración, seguridad y mantenimiento del sistema operativo.
- Objetivo: Estandarización y "Piloto Automático".
- Funciones Clave:
    - Actualizaciones Desatendidas: Parches de seguridad automáticos a las 04:00 AM.
    - Docker Safety Lock: Impide que Docker arranque en titan-hub si los discos del NAS no están montados.

Ejecución del Mantenimiento:

```Bash
# Aplicar configuración a todo el clúster
ansible-playbook -i inventory/hosts.ini playbooks/site.yml
```
## 🐳 Capa 3: Aplicaciones (Docker)
Los servicios finales corren containerizados, principalmente sobre el nodo titan-hub (VM 100).
Gestión: Híbrida (Portainer / Docker Compose).
Protección: Gestionada por el rol docker_stack de Ansible.

