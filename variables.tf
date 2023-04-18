variable "name" {
  type = string
}
variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "private_cluster_enabled" {
  type    = bool
  default = true
}

variable "private_dns_zone_id" {
  type    = string
  default = null
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "sku_tier" {
  type    = string
  default = "Free"
}

variable "node_pool_name" {
  type = string
}

variable "enable_auto_scaling" {
  type    = bool
  default = true
}

variable "min_count" {
  type    = number
  default = null
}

variable "max_count" {
  type    = number
  default = null
}

variable "node_count" {
  type    = number
  default = 1
}

variable "only_critical_addons_enabled" {
  type = bool
  default = true
}

variable "node_labels" {
  type    = map(string)
  default = {}
}

variable "vm_size" {
  type = string
}

variable "vnet_subnet_id_nodes" {
  type = string
}

variable "vnet_subnet_id_services" {
  type = list(any)
}

variable "max_pods" {
  type    = number
  default = 110
}

variable "os_disk_type" {
  type    = string
  default = "Managed"
}

variable "os_disk_size_gb" {
  type = number
}

variable "zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "nodepool_adv_config" {
  type    = any
  default = {}
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "load_balancer_sku" {
  type    = string
  default = "standard"
}

variable "network_plugin" {
  type    = string
  default = "kubenet"
}

variable "pod_cidr" {
  type    = string
  default = "172.27.0.0/16"
}

variable "service_cidr" {
  type    = string
  default = "172.28.0.0/16"
}

variable "dns_service_ip" {
  type    = string
  default = "172.28.0.10"
}

variable "network_policy" {
  type    = string
  default = "calico"
}

variable "outbound_type" {
  type    = string
  default = "userDefinedRouting"
}

variable "admin_group_object_ids" {
  type = list(any)
  #  default = ["<id>", "<id>"]
  default = []
}

variable "admin_username" {
  type      = string
  default   = "aksadmin"
  sensitive = true
}

variable "key_data" {
  type      = string
  sensitive = true
}