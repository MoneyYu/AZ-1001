terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "group_postfix" {
  type = string
}

variable "user_name" {
  type    = string
  default = "demouser"
}

variable "user_passowrd" {
  type    = string
  default = "Azuredemo2020"
}

locals {
  group_name  = "AZ1001-${var.group_postfix}"
  location    = "eastus"
  random_str  = "dog"
  admin_oid   = "b8e50bc5-6559-4643-a003-2807a8d707f7"
  lab_name  = "lab"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "azurerm_client_config" "current" {}

resource "random_string" "rid" {
  length  = 3
  special = false
  numeric = false
  upper   = false
}

# resource "random_integer" "rint" {
#   min = 100
#   max = 999
# }

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "az1001" {
  name     = local.group_name
  location = local.location

  tags = {
    environment = local.group_name
  }
}
