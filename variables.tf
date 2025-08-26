# variable not present on azurerm_kubernetes_cluster
variable "vnet_subnet_id_services" {
  type = list(any)
}

# azurerm_kubernetes_cluster vars
variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "default_node_pool" {
  type = object({
    name                          = string
    vm_size                       = string
    capacity_reservation_group_id = optional(string)
    auto_scaling_enabled          = optional(bool)
    host_encryption_enabled       = optional(bool)
    node_public_ip_enabled        = optional(bool)
    gpu_instance                  = optional(string)
    host_group_id                 = optional(string)
    kubelet_config = optional(object({
      allowed_unsafe_sysctls    = optional(list(string))
      container_log_max_line    = optional(number)
      container_log_max_size_mb = optional(number)
      cpu_cfs_quota_enabled     = optional(bool)
      cpu_cfs_quota_period      = optional(string)
      cpu_manager_policy        = optional(string)
      image_gc_high_threshold   = optional(number)
      image_gc_low_threshold    = optional(number)
      pod_max_pid               = optional(number)
      topology_manager_policy   = optional(string)
    }))
    linux_os_config = optional(object({
      swap_file_size_mb             = optional(number)
      transparent_huge_page_defrag  = optional(string)
      transparent_huge_page_enabled = optional(string)
      sysctl_config = optional(object({
        fs_aio_max_nr                      = optional(number)
        fs_file_max                        = optional(number)
        fs_inotify_max_user_watches        = optional(number)
        fs_nr_open                         = optional(number)
        kernel_threads_max                 = optional(number)
        net_core_netdev_max_backlog        = optional(number)
        net_core_optmem_max                = optional(number)
        net_core_rmem_default              = optional(number)
        net_core_rmem_max                  = optional(number)
        net_core_somaxconn                 = optional(number)
        net_core_wmem_default              = optional(number)
        net_core_wmem_max                  = optional(number)
        net_ipv4_ip_local_port_range_max   = optional(number)
        net_ipv4_ip_local_port_range_min   = optional(number)
        net_ipv4_neigh_default_gc_thresh1  = optional(number)
        net_ipv4_neigh_default_gc_thresh2  = optional(number)
        net_ipv4_neigh_default_gc_thresh3  = optional(number)
        net_ipv4_tcp_fin_timeout           = optional(number)
        net_ipv4_tcp_keepalive_intvl       = optional(number)
        net_ipv4_tcp_keepalive_probes      = optional(number)
        net_ipv4_tcp_keepalive_time        = optional(number)
        net_ipv4_tcp_max_syn_backlog       = optional(number)
        net_ipv4_tcp_max_tw_buckets        = optional(number)
        net_ipv4_tcp_tw_reuse              = optional(bool)
        net_netfilter_nf_conntrack_buckets = optional(number)
        net_netfilter_nf_conntrack_max     = optional(number)
        vm_max_map_count                   = optional(number)
        vm_swappiness                      = optional(number)
        vm_vfs_cache_pressure              = optional(number)
      }))
    }))
    fips_enabled      = optional(bool)
    kubelet_disk_type = optional(string)
    max_pods          = optional(number)
    node_network_profile = optional(object({
      allowed_host_ports = optional(object({
        port_start = optional(number)
        port_end   = optional(number)
        protocol   = optional(string)
      }))
      application_security_group_ids = optional(list(string))
      node_public_ip_tags            = optional(map(string))
    }))
    node_public_ip_prefix_id     = optional(string)
    node_labels                  = optional(map(string))
    only_critical_addons_enabled = optional(bool)
    orchestrator_version         = optional(string)
    os_disk_size_gb              = optional(number)
    os_disk_type                 = optional(string)
    os_sku                       = optional(string)
    pod_subnet_id                = optional(string)
    proximity_placement_group_id = optional(string)
    scale_down_mode              = optional(string)
    snapshot_id                  = optional(string)
    temporary_name_for_rotation  = optional(string)
    type                         = optional(string)
    tags                         = optional(map(string))
    ultra_ssd_enabled            = optional(string)
    upgrade_settings = optional(object({
      drain_timeout_in_minutes      = optional(number)
      node_soak_duration_in_minutes = optional(number)
      max_surge                     = string
    }))
    vnet_subnet_id   = string
    workload_runtime = optional(string)
    zones            = optional(list(string))
    max_count        = optional(number)
    min_count        = optional(number)
    node_count       = optional(number)
  })
}

# deprecated
variable "zones" {
  type    = list(any)
  default = [1, 2, 3]
}

variable "dns_prefix" {
  type    = string
  default = null
}

variable "dns_prefix_private_cluster" {
  type    = string
  default = null
}

variable "aci_connector_linux" {
  type = object({
    subnet_name = string
  })
  default = null
}

variable "automatic_upgrade_channel" {
  type    = string
  default = null
}

variable "api_server_access_profile" {
  type = object({
    authorized_ip_ranges = optional(list(string))
  })
  default = null
}

variable "auto_scaler_profile" {
  type = object({
    balance_similar_node_groups                   = optional(bool)
    daemonset_eviction_for_empty_nodes_enabled    = optional(bool)
    daemonset_eviction_for_occupied_nodes_enabled = optional(bool)
    expander                                      = optional(string)
    ignore_daemonsets_utilization_enabled         = optional(bool)
    max_graceful_termination_sec                  = optional(number)
    max_node_provisioning_time                    = optional(string)
    max_unready_nodes                             = optional(number)
    max_unready_percentage                        = optional(number)
    new_pod_scale_up_delay                        = optional(string)
    scale_down_delay_after_add                    = optional(string)
    scale_down_delay_after_delete                 = optional(string)
    scale_down_delay_after_failure                = optional(string)
    scan_interval                                 = optional(string)
    scale_down_unneeded                           = optional(string)
    scale_down_unready                            = optional(string)
    scale_down_utilization_threshold              = optional(number)
    empty_bulk_delete_max                         = optional(number)
    skip_nodes_with_local_storage                 = optional(bool)
    skip_nodes_with_system_pods                   = optional(bool)
  })
  default = null
}


variable "azure_active_directory_role_based_access_control" {
  type = object({
    tenant_id              = optional(string)
    admin_group_object_ids = optional(list(string))
    azure_rbac_enabled     = optional(bool)
  })
  default = {
    azure_rbac_enabled     = true
    admin_group_object_ids = []
  }
}

variable "azure_policy_enabled" {
  type    = bool
  default = false
}

variable "confidential_computing" {
  type = object({
    sgx_quote_helper_enabled = bool
  })
  default = null
}

variable "cost_analysis_enabled" {
  type    = bool
  default = false
}

variable "custom_ca_trust_certificates_base64" {
  type    = list(string)
  default = null
}

variable "disk_encryption_set_id" {
  type    = string
  default = null
}

variable "edge_zone" {
  type    = string
  default = null
}

variable "http_application_routing_enabled" {
  type    = bool
  default = false
}

variable "http_proxy_config" {
  type = object({
    http_proxy  = optional(string)
    https_proxy = optional(string)
    no_proxy    = optional(string)
    trusted_ca  = optional(string)
  })
  default = null
}

variable "identity" {
  description = "Specifies the type of Managed Service Identity that should be configured on this resource"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = {
    type = "UserAssigned"
  }
}

variable "image_cleaner_enabled" {
  type    = bool
  default = true
}

variable "image_cleaner_interval_hours" {
  type    = number
  default = 48
}

variable "ingress_application_gateway" {
  type = object({
    gateway_id   = optional(string)
    gateway_name = optional(string)
    subnet_cidr  = optional(string)
    subnet_id    = optional(string)
  })
  default = null
}

variable "key_management_service" {
  type = object({
    key_vault_key_id         = string
    key_vault_network_access = optional(string)
  })
  default = null
}

variable "key_vault_secrets_provider" {
  type = object({
    secret_rotation_enabled  = optional(bool)
    secret_rotation_interval = optional(string)
  })
  default = {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
}

variable "kubelet_identity" {
  type = object({
    client_id                 = optional(string)
    object_id                 = optional(string)
    user_assigned_identity_id = optional(string)
  })
  default = null
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "linux_profile" {
  type = object({
    admin_username = string
    ssh_key = optional(object({
      key_data = string
    }))
  })
  default = {
    admin_username = "admin"
  }
}

variable "key_data" {
  description = "this variable contains sensitive information this value comes from a vault. If you are not going to use a vault you can setup key_data using the variable above"
  type        = string
  sensitive   = true
  default     = null
}

variable "local_account_disabled" {
  type    = bool
  default = false
}

variable "maintenance_window" {
  type = object({
    allowed = optional(list(object({
      day   = string
      hours = list(number)
    })))
    not_allowed = optional(list(object({
      end   = string
      start = string
    })))
  })
  default = null
}

variable "maintenance_window_auto_upgrade" {
  type = object({
    frequency    = string
    interval     = string
    duration     = number
    day_of_week  = optional(string)
    day_of_month = optional(number)
    week_index   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    start_date   = optional(string)
    not_allowed = optional(list(object({
      end   = string
      start = string
    })))
  })
  default = null
}

variable "maintenance_window_node_os" {
  type = object({
    frequency    = string
    interval     = string
    duration     = number
    day_of_week  = optional(string)
    day_of_month = optional(number)
    week_index   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string)
    start_date   = optional(string)
    not_allowed = optional(list(object({
      end   = string
      start = string
    })))
  })
  default = null
}

variable "microsoft_defender" {
  type = object({
    log_analytics_workspace_id = string
  })
  default = null
}

variable "monitor_metrics" {
  type = object({
    annotations_allowed = optional(list(string))
    labels_allowed      = optional(list(string))
  })
  default = null
}

variable "network_profile" {
  type = object({
    network_plugin      = string
    network_mode        = optional(string)
    network_policy      = optional(string)
    dns_service_ip      = optional(string)
    network_data_plane  = optional(string)
    network_plugin_mode = optional(string)
    outbound_type       = optional(string)
    pod_cidr            = optional(string)
    pod_cidrs           = optional(list(string))
    service_cidr        = optional(string)
    service_cidrs       = optional(list(string))
    ip_versions         = optional(list(string))
    load_balancer_sku   = optional(string)
    load_balancer_profile = optional(object({
      backend_pool_type           = optional(string)
      idle_timeout_in_minutes     = optional(number)
      managed_outbound_ip_count   = optional(number)
      managed_outbound_ipv6_count = optional(number)
      outbound_ip_address_ids     = optional(list(string))
      outbound_ip_prefix_ids      = optional(list(string))
      outbound_ports_allocated    = optional(number)
    }))
    nat_gateway_profile = optional(object({
      idle_timeout_in_minutes   = optional(number)
      managed_outbound_ip_count = optional(number)
    }))
  })
  default = {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "calico"
    dns_service_ip      = "172.28.0.10"
    outbound_type       = "userDefinedRouting"
    pod_cidr            = "172.27.0.0/16"
    service_cidr        = "172.28.0.0/16"
    load_balancer_sku   = "standard"
  }
}

variable "node_os_upgrade_channel" {
  type    = string
  default = "NodeImage"
}

variable "node_resource_group" {
  type    = string
  default = null
}

variable "oidc_issuer_enabled" {
  type    = bool
  default = false
}

variable "oms_agent" {
  type = object({
    log_analytics_workspace_id      = string
    msi_auth_for_monitoring_enabled = optional(bool)
  })
  default = null
}

variable "open_service_mesh_enabled" {
  type    = bool
  default = false
}

variable "private_cluster_enabled" {
  type    = bool
  default = true
}

variable "private_dns_zone_id" {
  type    = string
  default = null
}

variable "private_cluster_public_fqdn_enabled" {
  type    = bool
  default = false
}

variable "service_mesh_profile" {
  type = object({
    mode                             = string
    revisions                        = optional(list(string))
    internal_ingress_gateway_enabled = optional(bool)
    external_ingress_gateway_enabled = optional(bool)
    certificate_authority = optional(object({
      key_vault_id           = string
      root_cert_object_name  = string
      cert_chain_object_name = string
      cert_object_name       = string
      key_object_name        = string
    }))
  })
  default = null
}

variable "workload_autoscaler_profile" {
  type = object({
    keda_enabled                    = optional(bool)
    vertical_pod_autoscaler_enabled = optional(bool)
  })
  default = null
}

variable "workload_identity_enabled" {
  type    = bool
  default = false
}

variable "role_based_access_control_enabled" {
  type    = bool
  default = true
}

variable "run_command_enabled" {
  type    = bool
  default = true
}

variable "service_principal" {
  type = object({
    client_id     = string
    client_secret = optional(string)
  })
  default = null
}

variable "client_secret" {
  description = "this variable contains sensitive information this value comes from a vault. If you are not going to use a vault you can setup key_data using the variable above"
  type        = string
  sensitive   = true
  default     = null
}

variable "sku_tier" {
  type    = string
  default = "Free"
}

variable "storage_profile" {
  type = object({
    blob_driver_enabled         = optional(bool)
    disk_driver_enabled         = optional(bool)
    file_driver_enabled         = optional(bool)
    snapshot_controller_enabled = optional(bool)
  })
  default = null
}

variable "support_plan" {
  type    = string
  default = "KubernetesOfficial"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "upgrade_override" {
  type = object({
    force_upgrade_enabled = bool
    effective_until       = optional(string)
  })
  default = null
}

variable "web_app_routing" {
  type = object({
    dns_zone_ids             = list(string)
    default_nginx_controller = optional(string)
  })
  default = null
}

variable "windows_profile" {
  type = object({
    admin_username = string
    admin_password = optional(string)
    license        = optional(string)
    gmsa = optional(object({
      dns_server  = string
      root_domain = string
    }))
  })
  default = null
}

variable "admin_password" {
  description = "this variable contains sensitive information this value comes from a vault. If you are not going to use a vault you can setup key_data using the variable above"
  type        = string
  sensitive   = true
  default     = null
}

variable "azure_ad_groups_lock_contributor" {
  type    = list(string)
  default = []
}