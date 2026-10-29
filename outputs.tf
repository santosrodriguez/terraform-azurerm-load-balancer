output "id" {
  description = "Load balancer resource ID."
  value       = azurerm_lb.this.id
}

output "name" {
  description = "Load balancer name."
  value       = azurerm_lb.this.name
}

output "frontend_ip_configuration_names" {
  description = "Frontend IP configuration names."
  value       = [for f in azurerm_lb.this.frontend_ip_configuration : f.name]
}

output "backend_address_pool_ids" {
  description = "Backend pool IDs keyed by pool name."
  value       = { for k, v in azurerm_lb_backend_address_pool.this : k => v.id }
}

output "probe_ids" {
  description = "Probe IDs keyed by probe name."
  value       = { for k, v in azurerm_lb_probe.this : k => v.id }
}

output "rule_ids" {
  description = "Load-balancing rule IDs keyed by rule name."
  value       = { for k, v in azurerm_lb_rule.this : k => v.id }
}

output "nat_pool_ids" {
  description = "NAT pool IDs keyed by pool name."
  value       = { for k, v in azurerm_lb_nat_pool.this : k => v.id }
}


output "public_ip_ids" {
  description = "Public IP IDs created by the module, keyed by frontend name."
  value       = { for k, v in azurerm_public_ip.this : k => v.id }
}
