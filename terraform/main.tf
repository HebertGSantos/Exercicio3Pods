terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "2.25"
    }
  }
}

provider "azurerm" {
    features {
    }
}

variable "client" {
  type = string
}

variable "secret" {
  type = string
}

resource "azurerm_resource_group" "rg-aula-infra" {
    location = "eastus"
    name = "rg-aula-infra"
}

resource "azurerm_kubernetes_cluster" "aks-aula-infra" {
  name                = "aks-aula-infra"
  location            = azurerm_resource_group.rg-aula-infra.location
  resource_group_name = azurerm_resource_group.rg-aula-infra.name
  dns_prefix          = "aks-aula-infra"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  service_principal {
    client_id = var.client
    client_secret = var.secret
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    http_application_routing {
      enabled = true
    }
  }

  tags = {
    Environment = "Production"
  }
}

# Only necessary when you need a private container registry

# resource "azurerm_container_registry" "acr-aula-infra" {
#   name                = "aulainfraacr"
#   resource_group_name = azurerm_resource_group.rg-aula-infra.name
#   location            = azurerm_resource_group.rg-aula-infra.location
#   sku                 = "Basic"
#   admin_enabled       = false
# }

# data "azuread_service_principal" "aks_principal" {
#     application_id = var.client
# }

# resource "azurerm_role_assignment" "acrpull-aula-infra" {
#   scope = azurerm_container_registry.acr-aula-infra.id
#   role_definition_name = "AcrPull"
#   principal_id = data.azuread_service_principal.aks_principal.id
#   skip_service_principal_aad_check = true
# }