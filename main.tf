resource "azurerm_user_assigned_identity" "mi-aks" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = "mi-${var.name}"
  tags                = local.tags
  lifecycle {
    ignore_changes = [
      tags["create_date"]
    ]
  }
}

resource "azurerm_role_assignment" "aks_mi_operator" {
  depends_on = [
    azurerm_user_assigned_identity.mi-aks
  ]
  for_each             = toset(lookup(var.azure_active_directory_role_based_access_control, "admin_group_object_ids", null))
  scope                = azurerm_user_assigned_identity.mi-aks.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "aks_mi_contributor_udr" {
  depends_on = [
    azurerm_user_assigned_identity.mi-aks, data.azurerm_subnet.subnetaks
  ]
  scope                = data.azurerm_subnet.subnetaks.route_table_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-aks.principal_id
}

resource "azurerm_role_assignment" "aks_mi_contributor_subnet_node" {
  depends_on = [
    azurerm_user_assigned_identity.mi-aks, data.azurerm_subnet.subnetaks
  ]
  scope                = lookup(var.default_node_pool, "vnet_subnet_id", null)
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-aks.principal_id
}

resource "azurerm_role_assignment" "aks_mi_contributor_subnet_svc" {
  depends_on = [
    azurerm_user_assigned_identity.mi-aks, data.azurerm_subnet.subnetaks
  ]
  for_each             = toset(var.vnet_subnet_id_services)
  scope                = each.key
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-aks.principal_id
}

resource "azurerm_role_assignment" "aks_mi_dns_contributor" {
  count                = var.private_cluster_enabled ? 1 : 0
  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-aks.principal_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  depends_on = [
    azurerm_user_assigned_identity.mi-aks, azurerm_role_assignment.aks_mi_contributor_udr, azurerm_role_assignment.aks_mi_dns_contributor
  ]
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  default_node_pool {
    name                          = var.default_node_pool.name
    vm_size                       = var.default_node_pool.vm_size
    capacity_reservation_group_id = lookup(var.default_node_pool, "capacity_reservation_group_id", null)
    custom_ca_trust_enabled       = lookup(var.default_node_pool, "custom_ca_trust_enabled", null)
    enable_auto_scaling           = lookup(var.default_node_pool, "enable_auto_scaling", true)
    enable_host_encryption        = lookup(var.default_node_pool, "enable_host_encryption", null)
    enable_node_public_ip         = lookup(var.default_node_pool, "enable_node_public_ip", false)
    gpu_instance                  = lookup(var.default_node_pool, "gpu_instance", null)
    host_group_id                 = lookup(var.default_node_pool, "host_group_id", null)
    dynamic "kubelet_config" {
      for_each = var.default_node_pool.kubelet_config != null ? [var.default_node_pool.kubelet_config] : []
      content {
        allowed_unsafe_sysctls    = lookup(kubelet_config.value, "allowed_unsafe_sysctls", null)
        container_log_max_line    = lookup(kubelet_config.value, "container_log_max_line", null)
        container_log_max_size_mb = lookup(kubelet_config.value, "container_log_max_size_mb", null)
        cpu_cfs_quota_enabled     = lookup(kubelet_config.value, "cpu_cfs_quota_enabled", null)
        cpu_cfs_quota_period      = lookup(kubelet_config.value, "cpu_cfs_quota_period", null)
        cpu_manager_policy        = lookup(kubelet_config.value, "cpu_manager_policy", null)
        image_gc_high_threshold   = lookup(kubelet_config.value, "image_gc_high_threshold", null)
        image_gc_low_threshold    = lookup(kubelet_config.value, "image_gc_low_threshold", null)
        pod_max_pid               = lookup(kubelet_config.value, "pod_max_pid", null)
        topology_manager_policy   = lookup(kubelet_config.value, "topology_manager_policy", null)
      }
    }
    dynamic "linux_os_config" {
      for_each = var.default_node_pool.linux_os_config != null ? [var.default_node_pool.linux_os_config] : []
      content {
        swap_file_size_mb             = lookup(linux_os_config.value, "swap_file_size_mb", null)
        transparent_huge_page_defrag  = lookup(linux_os_config.value, "transparent_huge_page_defrag", null)
        transparent_huge_page_enabled = lookup(linux_os_config.value, "transparent_huge_page_enabled", null)
        dynamic "sysctl_config" {
          for_each = linux_os_config.value.sysctl_config != null ? [linux_os_config.value.sysctl_config] : []
          content {
            fs_aio_max_nr                      = lookup(sysctl_config.value, "fs_aio_max_nr", null)
            fs_file_max                        = lookup(sysctl_config.value, "fs_file_max", null)
            fs_inotify_max_user_watches        = lookup(sysctl_config.value, "fs_inotify_max_user_watches", null)
            fs_nr_open                         = lookup(sysctl_config.value, "fs_nr_open", null)
            kernel_threads_max                 = lookup(sysctl_config.value, "kernel_threads_max", null)
            net_core_netdev_max_backlog        = lookup(sysctl_config.value, "net_core_netdev_max_backlog", null)
            net_core_optmem_max                = lookup(sysctl_config.value, "net_core_optmem_max", null)
            net_core_rmem_default              = lookup(sysctl_config.value, "net_core_rmem_default", null)
            net_core_rmem_max                  = lookup(sysctl_config.value, "net_core_rmem_max", null)
            net_core_somaxconn                 = lookup(sysctl_config.value, "net_core_somaxconn", null)
            net_core_wmem_default              = lookup(sysctl_config.value, "net_core_wmem_default", null)
            net_core_wmem_max                  = lookup(sysctl_config.value, "net_core_wmem_max", null)
            net_ipv4_ip_local_port_range_max   = lookup(sysctl_config.value, "net_ipv4_ip_local_port_range_max", null)
            net_ipv4_ip_local_port_range_min   = lookup(sysctl_config.value, "net_ipv4_ip_local_port_range_min", null)
            net_ipv4_neigh_default_gc_thresh1  = lookup(sysctl_config.value, "net_ipv4_neigh_default_gc_thresh1", null)
            net_ipv4_neigh_default_gc_thresh2  = lookup(sysctl_config.value, "net_ipv4_neigh_default_gc_thresh2", null)
            net_ipv4_neigh_default_gc_thresh3  = lookup(sysctl_config.value, "net_ipv4_neigh_default_gc_thresh3", null)
            net_ipv4_tcp_fin_timeout           = lookup(sysctl_config.value, "net_ipv4_tcp_fin_timeout", null)
            net_ipv4_tcp_keepalive_intvl       = lookup(sysctl_config.value, "net_ipv4_tcp_keepalive_intvl", null)
            net_ipv4_tcp_keepalive_probes      = lookup(sysctl_config.value, "net_ipv4_tcp_keepalive_probes", null)
            net_ipv4_tcp_keepalive_time        = lookup(sysctl_config.value, "net_ipv4_tcp_keepalive_time", null)
            net_ipv4_tcp_max_syn_backlog       = lookup(sysctl_config.value, "net_ipv4_tcp_max_syn_backlog", null)
            net_ipv4_tcp_max_tw_buckets        = lookup(sysctl_config.value, "net_ipv4_tcp_max_tw_buckets", null)
            net_ipv4_tcp_tw_reuse              = lookup(sysctl_config.value, "net_ipv4_tcp_tw_reuse", false)
            net_netfilter_nf_conntrack_buckets = lookup(sysctl_config.value, "net_netfilter_nf_conntrack_buckets", null)
            net_netfilter_nf_conntrack_max     = lookup(sysctl_config.value, "net_netfilter_nf_conntrack_max", null)
            vm_max_map_count                   = lookup(sysctl_config.value, "vm_max_map_count", null)
            vm_swappiness                      = lookup(sysctl_config.value, "vm_swappiness", null)
            vm_vfs_cache_pressure              = lookup(sysctl_config.value, "vm_vfs_cache_pressure", null)
          }
        }
      }
    }
    fips_enabled       = lookup(var.default_node_pool, "fips_enabled", null)
    kubelet_disk_type  = lookup(var.default_node_pool, "kubelet_disk_type", null)
    max_pods           = lookup(var.default_node_pool, "max_pods", 110)
    message_of_the_day = lookup(var.default_node_pool, "message_of_the_day", null)
    dynamic "node_network_profile" {
      for_each = var.default_node_pool.node_network_profile != null ? [var.default_node_pool.node_network_profile] : []
      content {
        dynamic "allowed_host_ports" {
          for_each = node_network_profile.value.allowed_host_ports != null ? [node_network_profile.value.allowed_host_ports] : []
          content {
            port_start = lookup(allowed_host_ports.value, "port_start", null)
            port_end   = lookup(allowed_host_ports.value, "port_end", null)
            protocol   = lookup(allowed_host_ports.value, "protocol", null)
          }
        }
        node_public_ip_tags            = lookup(node_network_profile.value, "node_public_ip_tags", null)
        application_security_group_ids = lookup(node_network_profile.value, "application_security_group_ids", null)
      }
    }
    node_public_ip_prefix_id     = lookup(var.default_node_pool, "node_public_ip_prefix_id", null)
    node_labels                  = lookup(var.default_node_pool, "node_labels", null)
    only_critical_addons_enabled = lookup(var.default_node_pool, "only_critical_addons_enabled", true)
    orchestrator_version         = lookup(var.default_node_pool, "orchestrator_version", null)
    os_disk_size_gb              = lookup(var.default_node_pool, "os_disk_size_gb", 64)
    os_disk_type                 = lookup(var.default_node_pool, "os_disk_type", "Managed")
    os_sku                       = lookup(var.default_node_pool, "os_sku", "Ubuntu")
    pod_subnet_id                = lookup(var.default_node_pool, "pod_subnet_id", null)
    proximity_placement_group_id = lookup(var.default_node_pool, "proximity_placement_group_id", null)
    scale_down_mode              = lookup(var.default_node_pool, "scale_down_mode", "Delete")
    snapshot_id                  = lookup(var.default_node_pool, "snapshot_id", null)
    temporary_name_for_rotation  = lookup(var.default_node_pool, "temporary_name_for_rotation", null)
    type                         = lookup(var.default_node_pool, "type", "VirtualMachineScaleSets")
    tags                         = lookup(var.default_node_pool, "tags", null)
    ultra_ssd_enabled            = lookup(var.default_node_pool, "ultra_ssd_enabled", false)
    dynamic "upgrade_settings" {
      for_each = var.default_node_pool.upgrade_settings != null ? [var.default_node_pool.upgrade_settings] : []
      content {
        drain_timeout_in_minutes      = lookup(upgrade_settings.value, "drain_timeout_in_minutes", 30)
        node_soak_duration_in_minutes = lookup(upgrade_settings.value, "node_soak_duration_in_minutes", 0)
        max_surge                     = upgrade_settings.value.max_surge
      }
    }
    vnet_subnet_id   = lookup(var.default_node_pool, "vnet_subnet_id", null)
    workload_runtime = lookup(var.default_node_pool, "workload_runtime", null)
    zones            = var.zones == null ? lookup(var.default_node_pool, "zones", null) : var.zones
    max_count        = lookup(var.default_node_pool, "max_count", null)
    min_count        = lookup(var.default_node_pool, "min_count", null)
    node_count       = lookup(var.default_node_pool, "node_count", null)
  }
  dns_prefix                 = var.dns_prefix == null ? var.name : var.dns_prefix
  dns_prefix_private_cluster = var.dns_prefix_private_cluster
  dynamic "aci_connector_linux" {
    for_each = var.aci_connector_linux != null ? [var.aci_connector_linux] : []
    content {
      subnet_name = aci_connector_linux.value.subnet_name
    }
  }
  automatic_channel_upgrade = var.automatic_channel_upgrade
  dynamic "api_server_access_profile" {
    for_each = var.api_server_access_profile != null ? [var.api_server_access_profile] : []
    content {
      authorized_ip_ranges     = lookup(api_server_access_profile.value, "authorized_ip_ranges", null)
      subnet_id                = lookup(api_server_access_profile.value, "subnet_id", null)
      vnet_integration_enabled = lookup(api_server_access_profile.value, "vnet_integration_enabled", null)
    }
  }
  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile != null ? [var.auto_scaler_profile] : []
    content {
      balance_similar_node_groups      = lookup(auto_scaler_profile.value, "balance_similar_node_groups", false)
      expander                         = lookup(auto_scaler_profile.value, "expander", "random")
      max_graceful_termination_sec     = lookup(auto_scaler_profile.value, "max_graceful_termination_sec", 600)
      max_node_provisioning_time       = lookup(auto_scaler_profile.value, "max_node_provisioning_time", "15m")
      max_unready_nodes                = lookup(auto_scaler_profile.value, "max_unready_nodes", 3)
      max_unready_percentage           = lookup(auto_scaler_profile.value, "max_unready_percentage", 45)
      new_pod_scale_up_delay           = lookup(auto_scaler_profile.value, "new_pod_scale_up_delay", "10s")
      scale_down_delay_after_add       = lookup(auto_scaler_profile.value, "scale_down_delay_after_add", "10m")
      scale_down_delay_after_delete    = lookup(auto_scaler_profile.value, "scale_down_delay_after_delete", "10s")
      scale_down_delay_after_failure   = lookup(auto_scaler_profile.value, "scale_down_delay_after_failure", "3m")
      scan_interval                    = lookup(auto_scaler_profile.value, "scan_interval", "10s")
      scale_down_unneeded              = lookup(auto_scaler_profile.value, "scale_down_unneeded", "10m")
      scale_down_unready               = lookup(auto_scaler_profile.value, "scale_down_unready", "20m")
      scale_down_utilization_threshold = lookup(auto_scaler_profile.value, "scale_down_utilization_threshold", 0.5)
      empty_bulk_delete_max            = lookup(auto_scaler_profile.value, "empty_bulk_delete_max", 10)
      skip_nodes_with_local_storage    = lookup(auto_scaler_profile.value, "skip_nodes_with_local_storage", true)
      skip_nodes_with_system_pods      = lookup(auto_scaler_profile.value, "skip_nodes_with_system_pods", true)
    }
  }
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.azure_active_directory_role_based_access_control != null ? [var.azure_active_directory_role_based_access_control] : []
    content {
      managed                = lookup(azure_active_directory_role_based_access_control.value, "managed", null)
      tenant_id              = lookup(azure_active_directory_role_based_access_control.value, "tenant_id", null)
      admin_group_object_ids = lookup(azure_active_directory_role_based_access_control.value, "admin_group_object_ids", null)
      azure_rbac_enabled     = lookup(azure_active_directory_role_based_access_control.value, "azure_rbac_enabled", null)
     }
  }
  azure_policy_enabled = var.azure_policy_enabled
  dynamic "confidential_computing" {
    for_each = var.confidential_computing != null ? [var.confidential_computing] : []
    content {
      sgx_quote_helper_enabled = confidential_computing.value.sgx_quote_helper_enabled
    }
  }
  cost_analysis_enabled               = var.cost_analysis_enabled
  custom_ca_trust_certificates_base64 = var.custom_ca_trust_certificates_base64
  disk_encryption_set_id              = var.disk_encryption_set_id
  edge_zone                           = var.edge_zone
  http_application_routing_enabled    = var.http_application_routing_enabled
  dynamic "http_proxy_config" {
    for_each = var.http_proxy_config != null ? [var.http_proxy_config] : []
    content {
      http_proxy  = lookup(http_proxy_config.value, "http_proxy", null)
      https_proxy = lookup(http_proxy_config.value, "https_proxy", null)
      no_proxy    = lookup(http_proxy_config.value, "no_proxy", null)
      trusted_ca  = lookup(http_proxy_config.value, "trusted_ca", null)
    }
  }
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = lookup(identity.value, "identity_ids", null) == null ? [azurerm_user_assigned_identity.mi-aks.id] : lookup(identity.value, "identity_ids", null)
    }
  }
  image_cleaner_enabled        = var.image_cleaner_enabled
  image_cleaner_interval_hours = var.image_cleaner_interval_hours
  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway != null ? [var.ingress_application_gateway] : []
    content {
      gateway_id   = lookup(ingress_application_gateway.value, "gateway_id", null)
      gateway_name = lookup(ingress_application_gateway.value, "gateway_name", null)
      subnet_cidr  = lookup(ingress_application_gateway.value, "subnet_cidr", null)
      subnet_id    = lookup(ingress_application_gateway.value, "subnet_id", null)
    }
  }
  dynamic "key_management_service" {
    for_each = var.key_management_service != null ? [var.key_management_service] : []
    content {
      key_vault_key_id         = key_management_service.value.key_vault_key_id
      key_vault_network_access = lookup(key_management_service.value, "key_vault_network_access", "Public")
    }
  }
  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider != null ? [var.key_vault_secrets_provider] : []
    content {
      secret_rotation_enabled  = lookup(key_vault_secrets_provider.value, "secret_rotation_enabled", null)
      secret_rotation_interval = lookup(key_vault_secrets_provider.value, "secret_rotation_interval", null)
    }
  }
  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity != null ? [var.kubelet_identity] : []
    content {
      client_id                 = lookup(kubelet_identity.value, "client_id", null)
      object_id                 = lookup(kubelet_identity.value, "object_id", null)
      user_assigned_identity_id = lookup(kubelet_identity.value, "user_assigned_identity_id", null)
    }
  }
  kubernetes_version = var.kubernetes_version
  dynamic "linux_profile" {
    for_each = var.linux_profile != null ? [var.linux_profile] : []
    content {
      admin_username = linux_profile.value.admin_username
      ssh_key {
        key_data = var.key_data == null ? linux_profile.value.ssh_key.key_data : var.key_data
      }
    }
  }
  local_account_disabled = var.local_account_disabled
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      dynamic "allowed" {
        for_each = maintenance_window.value.allowed != null ? [maintenance_window.value.allowed] : []
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }
      dynamic "not_allowed" {
        for_each = maintenance_window.value.not_allowed != null ? [maintenance_window.value.not_allowed] : []
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }
  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.maintenance_window_auto_upgrade != null ? [var.maintenance_window_auto_upgrade] : []
    content {
      frequency    = maintenance_window_auto_upgrade.value.frequency
      interval     = maintenance_window_auto_upgrade.value.interval
      duration     = maintenance_window_auto_upgrade.value.duration
      day_of_week  = lookup(maintenance_window_auto_upgrade.value, "day_of_week", null)
      day_of_month = lookup(maintenance_window_auto_upgrade.value, "day_of_month", null)
      week_index   = lookup(maintenance_window_auto_upgrade.value, "week_index", null)
      start_time   = lookup(maintenance_window_auto_upgrade.value, "start_time", null)
      utc_offset   = lookup(maintenance_window_auto_upgrade.value, "utc_offset", null)
      start_date   = lookup(maintenance_window_auto_upgrade.value, "start_date", null)
      dynamic "not_allowed" {
        for_each = maintenance_window_auto_upgrade.value.not_allowed != null ? [maintenance_window_auto_upgrade.value.not_allowed] : []
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }
  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os != null ? [var.maintenance_window_node_os] : []
    content {
      frequency    = maintenance_window_node_os.value.frequency
      interval     = maintenance_window_node_os.value.interval
      duration     = maintenance_window_node_os.value.duration
      day_of_week  = lookup(maintenance_window_node_os.value, "day_of_week", null)
      day_of_month = lookup(maintenance_window_node_os.value, "day_of_month", null)
      week_index   = lookup(maintenance_window_node_os.value, "week_index", null)
      start_time   = lookup(maintenance_window_node_os.value, "start_time", null)
      utc_offset   = lookup(maintenance_window_node_os.value, "utc_offset", null)
      start_date   = lookup(maintenance_window_node_os.value, "start_date", null)
      dynamic "not_allowed" {
        for_each = maintenance_window_node_os.value.not_allowed != null ? [maintenance_window_node_os.value.not_allowed] : []
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }
  dynamic "microsoft_defender" {
    for_each = var.microsoft_defender != null ? [var.microsoft_defender] : []
    content {
      log_analytics_workspace_id = microsoft_defender.value.log_analytics_workspace_id
    }
  }
  dynamic "monitor_metrics" {
    for_each = var.monitor_metrics != null ? [var.monitor_metrics] : []
    content {
      annotations_allowed = lookup(monitor_metrics.value, "annotations_allowed", null)
      labels_allowed      = lookup(monitor_metrics.value, "labels_allowed", null)
    }
  }
  dynamic "network_profile" {
    for_each = var.network_profile != null ? [var.network_profile] : []
    content {
      network_plugin      = network_profile.value.network_plugin
      network_mode        = lookup(network_profile.value, "network_mode", null)
      network_policy      = lookup(network_profile.value, "network_policy", null)
      dns_service_ip      = lookup(network_profile.value, "dns_service_ip", null)
      #docker_bridge_cidr = lookup(network_profile.value, "docker_bridge_cidr", null)
      network_data_plane  = lookup(network_profile.value, "network_data_plane", null)
      network_plugin_mode = lookup(network_profile.value, "network_plugin_mode", null)
      outbound_type       = lookup(network_profile.value, "outbound_type", null)
      pod_cidr            = lookup(network_profile.value, "pod_cidr", null)
      pod_cidrs           = lookup(network_profile.value, "pod_cidrs", null)
      service_cidr        = lookup(network_profile.value, "service_cidr", null)
      service_cidrs       = lookup(network_profile.value, "service_cidrs", null)
      ip_versions         = lookup(network_profile.value, "ip_versions", null)
      load_balancer_sku   = lookup(network_profile.value, "load_balancer_sku", null)
      dynamic "load_balancer_profile" {
        for_each = network_profile.value.load_balancer_profile != null ? [network_profile.value.load_balancer_profile] : []
        content {
          idle_timeout_in_minutes     = lookup(load_balancer_profile.value, "idle_timeout_in_minutes", 30)
          managed_outbound_ip_count   = lookup(load_balancer_profile.value, "managed_outbound_ip_count", null)
          managed_outbound_ipv6_count = lookup(load_balancer_profile.value, "managed_outbound_ipv6_count", null)
          outbound_ip_address_ids     = lookup(load_balancer_profile.value, "outbound_ip_address_ids", null)
          outbound_ip_prefix_ids      = lookup(load_balancer_profile.value, "outbound_ip_prefix_ids", null)
          outbound_ports_allocated    = lookup(load_balancer_profile.value, "outbound_ports_allocated", 0)
        }
      }
      dynamic "nat_gateway_profile" {
        for_each = network_profile.value.nat_gateway_profile != null ? [network_profile.value.nat_gateway_profile] : []
        content {
          idle_timeout_in_minutes   = lookup(nat_gateway_profile.value, "idle_timeout_in_minutes", 4)
          managed_outbound_ip_count = lookup(nat_gateway_profile.value, "managed_outbound_ip_count", null)
        }
      }
    }
  }
  node_os_channel_upgrade = var.node_os_channel_upgrade
  node_resource_group     = var.node_resource_group
  oidc_issuer_enabled     = var.oidc_issuer_enabled
  dynamic "oms_agent" {
    for_each = var.oms_agent != null ? [var.oms_agent] : []
    content {
      log_analytics_workspace_id      = oms_agent.value.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = lookup(oms_agent.value, "msi_auth_for_monitoring_enabled", null)
    }
  }
  open_service_mesh_enabled           = var.open_service_mesh_enabled
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_dns_zone_id
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled
  dynamic "service_mesh_profile" {
    for_each = var.service_mesh_profile != null ? [var.service_mesh_profile] : []
    content {
      mode                             = service_mesh_profile.value.mode
      internal_ingress_gateway_enabled = lookup(oms_agent.value, "internal_ingress_gateway_enabled", null)
      external_ingress_gateway_enabled = lookup(oms_agent.value, "external_ingress_gateway_enabled", null)
    }
  }
  dynamic "workload_autoscaler_profile" {
    for_each = var.workload_autoscaler_profile != null ? [var.workload_autoscaler_profile] : []
    content {
      keda_enabled                    = lookup(workload_autoscaler_profile.value, "keda_enabled", null)
      vertical_pod_autoscaler_enabled = lookup(oms_workload_autoscaler_profileagent.value, "vertical_pod_autoscaler_enabled", null)
    }
  }
  workload_identity_enabled         = var.workload_identity_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  role_based_access_control_enabled = var.role_based_access_control_enabled
  run_command_enabled               = var.run_command_enabled
  dynamic "service_principal" {
    for_each = var.service_principal != null ? [var.service_principal] : []
    content {
      client_id     = service_principal.value.client_id
      client_secret = var.client_secret == null ? service_principal.value.ssh_key.client_secret : var.client_secret
    }
  }
  sku_tier = var.sku_tier
  dynamic "storage_profile" {
    for_each = var.storage_profile != null ? [var.storage_profile] : []
    content {
      blob_driver_enabled         = lookup(storage_profile.value, "blob_driver_enabled", false)
      disk_driver_enabled         = lookup(storage_profile.value, "disk_driver_enabled", true)
      disk_driver_version         = lookup(storage_profile.value, "disk_driver_version", "v1")
      file_driver_enabled         = lookup(storage_profile.value, "file_driver_enabled", true)
      snapshot_controller_enabled = lookup(storage_profile.value, "snapshot_controller_enabled", true)
    }
  }
  support_plan = var.support_plan
  tags         = local.tags
  dynamic "web_app_routing" {
    for_each = var.web_app_routing != null ? [var.web_app_routing] : []
    content {
      dns_zone_id = web_app_routing.value.dns_zone_id
    }
  }
  dynamic "windows_profile" {
    for_each = var.windows_profile != null ? [var.windows_profile] : []
    content {
      admin_username = windows_profile.value.admin_username
      admin_password = var.admin_password == null ? lookup(windows_profile.value, "admin_password", null) : var.admin_password
      license        = lookup(windows_profile.value, "license", null)
      dynamic "gmsa" {
        for_each = windows_profile.value.gmsa != null ? [windows_profile.value.gmsa] : []
        content {
          dns_server  = gmsa.value.dns_server
          root_domain = gmsa.value.root_domain
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [
      # Since autoscaling is enabled, let's ignore changes to the node count.
      default_node_pool[0].node_count, tags["create_date"], linux_profile[0].ssh_key[0].key_data
    ]
  }
}