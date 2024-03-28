resource "azurerm_container_registry" "acr" {
  name                = "${local.lab_name}acr${local.random_str}"
  resource_group_name = azurerm_resource_group.az1001.name
  location            = azurerm_resource_group.az1001.location
  sku                 = "Premium"
  admin_enabled       = true

  georeplications {
    location                = "East Asia"
    zone_redundancy_enabled = false
    tags = {
      environment = local.group_name
    }
  }

  georeplications {
    location                = "SouthEastAsia"
    zone_redundancy_enabled = false
    tags = {
      environment = local.group_name
    }
  }

  georeplications {
    location                = "JapanWest"
    zone_redundancy_enabled = false
    tags = {
      environment = local.group_name
    }
  }

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${local.lab_name}-aks-${local.random_str}"
  location            = azurerm_resource_group.az1001.location
  resource_group_name = azurerm_resource_group.az1001.name
  dns_prefix          = "${local.lab_name}-aks-${local.random_str}"

  automatic_channel_upgrade = "stable"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = local.group_name
  }
}

# To link the ACR to the AKS
resource "azurerm_role_assignment" "aksroleassignment" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# Data Protection Backup Vault
resource "azurerm_data_protection_backup_vault" "abs" {
  name                = "${local.lab_name}-backup-vault-${local.random_str}"
  resource_group_name = azurerm_resource_group.az1001.name
  location            = azurerm_resource_group.az1001.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"

  tags = {
    environment = local.group_name
  }
}

# Aks Backup Policy
resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "example" {
  name                = "${local.lab_name}-backup-policy-${local.random_str}"
  resource_group_name = azurerm_resource_group.az1001.name
  vault_name          = azurerm_data_protection_backup_vault.abs.name

  backup_repeating_time_intervals = ["R/2021-05-23T02:30:00+00:00/P1W"]
  time_zone                       = "Taipei Standard Time"

  retention_rule {
    name     = "Daily"
    priority = 25

    life_cycle {
      duration        = "P84D"
      data_store_type = "OperationalStore"
    }

    criteria {
      absolute_criteria = "FirstOfDay"
    }
  }

  default_retention_rule {
    life_cycle {
      duration        = "P7D"
      data_store_type = "OperationalStore"
    }
  }
}
