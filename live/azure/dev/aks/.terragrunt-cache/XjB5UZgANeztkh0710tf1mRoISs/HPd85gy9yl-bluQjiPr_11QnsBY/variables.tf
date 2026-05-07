variable "cluster_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "node_count" {
  type    = number
  default = 2
}

variable "vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}

variable "vnet_subnet_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "network_plugin_mode" {
  type    = string
  default = null
}

variable "pod_cidr" {
  type    = string
  default = null
}

variable "outbound_type" {
  type    = string
  default = "loadBalancer"
}

variable "key_vault_secrets_provider_enabled" {
  type    = bool
  default = false
}
