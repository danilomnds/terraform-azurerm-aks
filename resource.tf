resource "azurerm_user_assigned_identity" "mi-aks" {
  resource_group_name = var.rg_name
  location            = var.location
  name                = "mi-${var.name}"
  tags                = local.tags
  lifecycle {
    ignore_changes = [
      # Since autoscaling is enabled, let's ignore changes to the node count.
      tags["create_date"]
    ]
  }
}

resource "azurerm_role_assignment" "aks_mi_operator" {
  depends_on = [
    azurerm_user_assigned_identity.mi-aks
  ]
  for_each             = toset(var.admin_group_object_ids)
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
  scope                = var.vnet_subnet_id_nodes
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
  scope                = lookup(local.private_dns_zone_id, var.location)
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-aks.principal_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  depends_on = [
    azurerm_user_assigned_identity.mi-aks, azurerm_role_assignment.aks_mi_contributor_udr, azurerm_role_assignment.aks_mi_dns_contributor
  ]
  name                    = var.name
  location                = var.location
  resource_group_name     = var.rg_name
  dns_prefix              = var.name
  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id     = var.private_dns_zone_id == null ? lookup(local.zone_id, var.location) : var.private_dns_zone_id
  kubernetes_version      = var.kubernetes_version
  sku_tier                = var.sku_tier
  linux_profile {
    admin_username = var.linux_username
    ssh_key {
      key_data = var.key_data
    }
  }
  default_node_pool {
    name                         = var.node_pool_name
    node_count                   = var.enable_auto_scaling == true ? null : var.node_count
    enable_auto_scaling          = var.enable_auto_scaling
    max_count                    = var.max_count
    min_count                    = var.min_count
    vm_size                      = var.vm_size
    vnet_subnet_id               = var.vnet_subnet_id_nodes
    max_pods                     = var.max_pods
    node_labels                  = var.node_labels
    only_critical_addons_enabled = var.only_critical_addons_enabled
    os_disk_type                 = var.os_disk_type
    os_disk_size_gb              = var.os_disk_size_gb
    zones                        = var.zones
    dynamic "linux_os_config" {
      for_each = lookup(var.nodepool_adv_config, "linux_os_config", null) != null ? tolist([var.nodepool_adv_config.linux_os_config]) : []
      content {
        swap_file_size_mb = lookup(linux_os_config.value, "swap_file_size_mb", null)
        dynamic "sysctl_config" {
          for_each = lookup(linux_os_config.value, "sysctl_config", null) != null ? tolist([linux_os_config.value.sysctl_config]) : []
          content {
            fs_aio_max_nr                      = lookup(sysctl_config.value, "fs_aio_max_nr", null) == null ? null : "IPv4"
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
            net_core_wmem_max                  = lookup(sysctl_config.value, "net_core_wmem_default", null)
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
            net_ipv4_tcp_tw_reuse              = lookup(sysctl_config.value, "net_ipv4_tcp_tw_reuse", null)
            net_netfilter_nf_conntrack_buckets = lookup(sysctl_config.value, "net_netfilter_nf_conntrack_buckets", null)
            net_netfilter_nf_conntrack_max     = lookup(sysctl_config.value, "net_netfilter_nf_conntrack_max", null)
            vm_max_map_count                   = lookup(sysctl_config.value, "vm_max_map_count", null)
            vm_swappiness                      = lookup(sysctl_config.value, "vm_swappiness", null)
            vm_vfs_cache_pressure              = lookup(sysctl_config.value, "vm_vfs_cache_pressure ", null)
          }
        }
        transparent_huge_page_defrag  = lookup(linux_os_config.value, "transparent_huge_page_defrag", null)
        transparent_huge_page_enabled = lookup(linux_os_config.value, "transparent_huge_page_enabled", null)
      }
    }
  }
  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? tolist([var.log_analytics_workspace_id]) : []
    content {
      log_analytics_workspace_id = oms_agent.value
    }
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mi-aks.id]
  }
  network_profile {
    load_balancer_sku  = var.load_balancer_sku
    network_plugin     = var.network_plugin
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
    pod_cidr           = var.network_plugin == "kubenet" ? var.pod_cidr : null
    network_policy     = var.network_policy
    outbound_type      = var.outbound_type
  }
  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }
  tags = local.tags
  lifecycle {
    ignore_changes = [
      # Since autoscaling is enabled, let's ignore changes to the node count.
      default_node_pool[0].node_count, tags["create_date"], linux_profile[0].ssh_key[0].key_data
    ]
  }
}