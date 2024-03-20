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
  location            = azurerm_resource_group.az104.location
  resource_group_name = azurerm_resource_group.az104.name
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

resource "azurerm_role_assignment" "aksroleassignment" {
  principal_id                     = azurerm_kubernetes_cluster.lab09c.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.lab09b.id
  skip_service_principal_aad_check = true
}