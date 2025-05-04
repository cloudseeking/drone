######################### NAMING CONVENTION #########################
module "labels" {
  source      = "git@github.com:SQ-Sandbox/terraform-azurerm-naming-module.git?ref=main"
  project     = "drone"
  environment = "dev"
  location    = "eastus2"
}
# output "naming_convention" {
#   description = "Todas as convenções de nomenclatura disponíveis"
#   value       = module.labels.naming_convention
# }

######################### RESOURCE GROUP #########################
module "resource_group" {
  source              = "git@github.com:SQ-Sandbox/terraform-azurerm-rg-module.git?ref=main"
  location            = module.labels.location
  resource_group_name = upper("${module.labels.resource_group_name}-001")
  tags                = merge(local.tags, {})
}

######################### VIRTUAL NETWORK #########################
module "virtual_network" {
  source = "git@github.com:SQ-Sandbox/terraform-azurerm-network-module.git?ref=main"
  # Resource Group
  create_resource_group = false
  resource_group_name   = module.resource_group.resource_group_name
  location              = module.resource_group.location
  vnet_name             = "${module.labels.vnet_name}-001"
  vnet_address_space    = ["10.10.0.0/16"]
  subnets = {
    private_subnet = {
      name             = "${module.labels.private_subnet_name}-001"
      address_prefixes = ["10.10.10.0/24"]
    }
    db_subnet = {
      name             = "${module.labels.db_subnet_name}-001"
      address_prefixes = ["10.10.11.0/24"]
    }
    public_subnet = {
      name             = "${module.labels.public_subnet_name}-001"
      address_prefixes = ["10.10.12.0/24"]
    }
  }
  tags = merge(local.tags, {})
}

######################### SSH KEY #########################
# Gerar chave SSH
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}
resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./private_key.pem"
  file_permission = "0600"
}
######################### LINUX VM #########################
module "vm_sqctrl" {
  depends_on          = [module.virtual_network]
  source              = "git@github.com:SQ-Sandbox/terraform-azurerm-vm-module.git?ref=main"
  name                = "${module.labels.server_name}-001"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  image_os            = "linux"
  size                = "Standard_B4ms"
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }
  # Credenciais
  admin_username = "adminuser"
  admin_password = "Cloudseek@2025"
  admin_ssh_keys = [
    {
      public_key = tls_private_key.ssh.public_key_openssh
    }
  ]
  disable_password_authentication = false
  # Rede
  subnet_id = module.virtual_network.subnet_ids[lower("${module.labels.private_subnet_name}-001")]
  # Opcional: escolher uma fonte de imagem
  # Usando uma das novas imagens pré-definidas
  os_simple  = "ubuntu_24_04_minimal"
  os_version = "latest"

  # Criando múltiplas VMs
  vm_count         = 1
  create_public_ip = false                               # (opcional)
  tags = merge(local.tags, {
    RESPONSAVEL       = "BRUNO CARDOSO"
    WAVE              = "LINUX"
    BACKUP            = "NAO"
    DOMINIO           = "LINUX"
    SO                = "DEBIAN 12"
    DISPONIBILIDADE   = "PARCIAL"
    RESERVA           = "NAO"
    START             = "8:00"
    START_OLD         = "8:01"
    STOP              = "20:00"
    STOP_OLD          = "20:01"
  })
}
output "resource_names" {
  description = "Nomes de todos os recursos"
  value = {
    linux_vm = {
      vmname = module.vm_sqctrl.vm_names
      ip     = module.vm_sqctrl.network_interface_private_ips
      ssh_command = "ssh -i ./private_key.pem adminuser@${module.vm_sqctrl.network_interface_private_ips[0]}"
    }
  }
}
