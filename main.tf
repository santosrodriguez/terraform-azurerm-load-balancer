terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }
}

resource "azurerm_public_ip" "this" {
  for_each = {
    for k, v in var.frontend_ip_configurations : k => v
    if try(v.create_public_ip, false)
  }

  name                = coalesce(try(each.value.public_ip_name, null), "pip-${var.name}-${each.key}")
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = try(each.value.public_ip_zones, null)
  domain_name_label   = try(each.value.domain_name_label, null)
  tags                = var.tags
}

resource "azurerm_lb" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  sku_tier            = var.sku_tier
  edge_zone           = var.edge_zone
  tags                = var.tags

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations

    content {
      name = frontend_ip_configuration.key

      subnet_id                     = try(frontend_ip_configuration.value.subnet_id, null)
      private_ip_address            = try(frontend_ip_configuration.value.private_ip_address, null)
      private_ip_address_allocation = try(frontend_ip_configuration.value.private_ip_address, null) != null ? "Static" : try(frontend_ip_configuration.value.private_ip_address_allocation, "Dynamic")
      private_ip_address_version    = try(frontend_ip_configuration.value.private_ip_address_version, "IPv4")
      public_ip_address_id          = try(frontend_ip_configuration.value.create_public_ip, false) ? azurerm_public_ip.this[frontend_ip_configuration.key].id : try(frontend_ip_configuration.value.public_ip_address_id, null)
      zones                         = try(frontend_ip_configuration.value.zones, null)
    }
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  for_each = var.backend_address_pools

  name            = each.key
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_lb_probe" "this" {

  for_each = var.probes

  name                = each.key
  loadbalancer_id     = azurerm_lb.this.id
  protocol            = upper(each.value.protocol)
  port                = each.value.port
  interval_in_seconds = try(each.value.interval_in_seconds, 5)
  number_of_probes    = try(each.value.number_of_probes, 2)
  request_path        = contains(["HTTP", "HTTPS"], upper(each.value.protocol)) ? each.value.request_path : null
  
 }


resource "azurerm_lb_rule" "this" {
  for_each = var.rules

  name                           = each.key
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = upper(each.value.protocol)
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this[each.value.backend_address_pool_name].id]
  probe_id                       = try(each.value.probe_name, null) != null ? azurerm_lb_probe.this[each.value.probe_name].id : null
  enable_floating_ip             = try(each.value.enable_floating_ip, false)
  disable_outbound_snat          = try(each.value.disable_outbound_snat, false)
  idle_timeout_in_minutes        = try(each.value.idle_timeout_in_minutes, 4)
  load_distribution              = try(each.value.load_distribution, "Default")
  enable_tcp_reset               = try(each.value.enable_tcp_reset, false)
}

resource "azurerm_lb_nat_pool" "this" {
  for_each = var.nat_pools

  name                           = each.key
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = upper(each.value.protocol)
  frontend_port_start            = each.value.frontend_port_start
  frontend_port_end              = each.value.frontend_port_end
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  idle_timeout_in_minutes        = try(each.value.idle_timeout_in_minutes, 4)
  floating_ip_enabled            = try(each.value.enable_floating_ip, false)
  tcp_reset_enabled              = try(each.value.enable_tcp_reset, false)
}
