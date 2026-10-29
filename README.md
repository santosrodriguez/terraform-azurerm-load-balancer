# Azure Load Balancer Terraform Module

## Introduction
Deploy secure, production-ready Load Balancer using Terraform.

## Usage

```hcl
module "lb" {
  source                             = "caresource.pe.jfrog.io/shared-tfmodules-internal__data/network/load-balancer"
  resource_group_name                = var.resource_group_name
  instance_number                    = 1
  environment                        = "dev"
  solution_name                      = "project"
  tags = {
    Environment : "DEV"
  }
}

```

## Inputs

| Name                                | Type           | Description                                       | Default    |
|--------------------------------------|----------------|---------------------------------------------------|------------|
| edge_zone | string | Specifies the Edge Zone within the Azure Region where this Load Balancer should exist | n/a |
| environment | string | Environment Name (DEV,CRT,etc...) | n/a |
| frontend_ip_configuration | list(object({})) | Frontend IP Configuration | [ {} ] |
| instance_number | string | Resource group name | n/a |
| location | string | Resource deployment location | "eastus" |
| resource_group_name | string | Resource group name | n/a |
| sku | string | Load Balancer SKU | "Standard" |
| sku_tier | string | Load Balancer Tier | "Regional" |
| solution_name | string | Name of project/solution to be deployed (crm-migration, tricare, etc...) | n/a |
| subnet_id | string | ID of subnet to be used by the load balancer | n/a |
| tags | map(string) | Resource tags to apply | n/a |


## Outputs

| Name                                 | Description                           |
|--------------------------------------|---------------------------------------|
| azurerm_lb                           | Load Balancer                         |

## Features

- Secure, configurable Load Balancer
- Tagging support

## Requirements

- Terraform >= 1.4.0
- AzureRM >= 3.0
