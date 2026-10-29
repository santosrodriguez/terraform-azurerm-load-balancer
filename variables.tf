variable "name" {
  type        = string
  description = "Name of the load balancer."
}

variable "location" {
  type        = string
  description = "Azure region for the load balancer and optional public IPs."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "sku_tier" {
  type        = string
  description = "Load balancer SKU tier."
  default     = "Regional"

  validation {
    condition     = contains(["Regional", "Global"], var.sku_tier)
    error_message = "sku_tier must be Regional or Global."
  }
}

variable "edge_zone" {
  type        = string
  description = "Optional edge zone."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}

variable "frontend_ip_configurations" {
  description = "Frontend IP configurations keyed by frontend name. Private frontend is the default pattern."
  type = map(object({
    subnet_id                     = optional(string)
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string, "Dynamic")
    private_ip_address_version    = optional(string, "IPv4")
    zones                         = optional(list(string))

    create_public_ip   = optional(bool, false)
    public_ip_name     = optional(string)
    public_ip_address_id = optional(string)
    public_ip_zones    = optional(list(string))
    domain_name_label  = optional(string)
  }))

  validation {
    condition = alltrue([
      for _, v in var.frontend_ip_configurations : (
        (try(v.subnet_id, null) != null) ||
        (try(v.create_public_ip, false) == true) ||
        (try(v.public_ip_address_id, null) != null)
      )
    ])
    error_message = "Each frontend must define either subnet_id, create_public_ip=true, or public_ip_address_id."
  }
}

variable "backend_address_pools" {
  description = "Backend address pools keyed by pool name. For VMSS, attach the pool IDs on the VMSS resource rather than managing individual backend addresses here."
  type = map(object({}))
  default = {}
}

variable "probes" {

  description = "Health probes keyed by probe name."
  type = map(object({
    protocol            = string
    port                = number
    request_path        = optional(string)
    interval_in_seconds = optional(number, 5)
    number_of_probes    = optional(number, 2)
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, v in var.probes : contains(["TCP", "HTTP", "HTTPS"], upper(v.protocol))
    ])
    error_message = "Probe protocol must be TCP, HTTP, or HTTPS."
  }

}
variable "rules" {
  description = "Load-balancing rules keyed by rule name."
  type = map(object({
    protocol                       = string
    frontend_port                  = number
    backend_port                   = number
    frontend_ip_configuration_name = string
    backend_address_pool_name      = string
    probe_name                     = optional(string)
    disable_outbound_snat          = optional(bool, false)
    enable_floating_ip             = optional(bool, false)
    idle_timeout_in_minutes        = optional(number, 4)
    load_distribution              = optional(string, "Default")
    enable_tcp_reset               = optional(bool, false)
  }))
  default = {}
}


variable "nat_pools" {
  description = "Inbound NAT pools keyed by name for VMSS instance access."
  type = map(object({
    protocol                       = string
    frontend_port_start            = number
    frontend_port_end              = number
    backend_port                   = number
    frontend_ip_configuration_name = string
    idle_timeout_in_minutes        = optional(number, 4)
    enable_floating_ip             = optional(bool, false)
    enable_tcp_reset               = optional(bool, false)
  }))
  default = {}
}
