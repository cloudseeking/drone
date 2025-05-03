terraform {
  backend "azurerm" {
    resource_group_name  = "rg-sh"
    storage_account_name = "satg"
    container_name       = "dronestate"
    key                  = "drone.tfstate"
  }
}
