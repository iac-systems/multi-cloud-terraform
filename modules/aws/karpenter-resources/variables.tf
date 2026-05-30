variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_certificate_authority_data" {
  type = string
}

variable "karpenter_service_account" {
  type    = string
  default = "karpenter"
}

variable "karpenter_node_role_name" {
  type = string
}

variable "interruption_queue_name" {
  type = string
}
