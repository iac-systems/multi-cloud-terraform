variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-hub-vpn"
}

variable "azure_bgp_asn" {
  description = "BGP ASN for Azure side"
  type        = number
  default     = 65020
}

variable "aws_peer_ip" {
  description = "Public IP of the AWS VPN endpoint"
  type        = string
}

variable "aws_peer_bgp_ip" {
  description = "BGP IP of the AWS VPN endpoint"
  type        = string
}

variable "azure_bgp_ip" {
  description = "BGP IP for the Azure VPN VM"
  type        = string
}

variable "shared_key" {
  description = "IPSec shared key"
  type        = string
  sensitive   = true
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vnet_address_space" {
  description = "Address space for the Hub VNet"
  type        = list(string)
  default     = ["10.100.0.0/16"]
}

variable "vpn_subnet_prefix" {
  description = "Subnet prefix for the VPN VM"
  type        = list(string)
  default     = ["10.100.1.0/24"]
}

variable "routeserver_subnet_prefix" {
  description = "Subnet prefix for the Route Server (must be RouteServerSubnet)"
  type        = list(string)
  default     = ["10.100.255.0/27"]
}
