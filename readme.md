# Module - Azure Kubernetes Services (AKS)
[![COE](https://img.shields.io/badge/Created%20By-CCoE-blue)]()
[![HCL](https://img.shields.io/badge/language-HCL-blueviolet)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/provider-Azure-blue)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

Module developed to standardize the AKS creation.

## Compatibility Matrix

| Module Version | Terraform Version | AzureRM Version |
|----------------|-------------------| --------------- |
| v1.0.0         | v1.4.5            | 3.52.0          |
| v2.0.0         | v1.9.2            | 3.112.0         |
| v2.1.0         | v1.12.2           | 4.40.0          |

## Release Notes

| Module Version | Note | 
|----------------|------|
| v1.0.0         | Initial Version |
| v2.0.0         | upgrade to azurerm 3.112 |
| v2.1.0         | upgrade to azurerm 4.40.0, change the default network mode azure cni overlay |

## Specifying a version

To avoid that your code get the latest module version, you can define the `?ref=***` in the URL to point to a specific version.
Note: The `?ref=***` refers a tag on the git module repo.

## Important considerations

- Adopting a MSFT recommendation, this module requires the creation of two subnets. One for nodepools and the another for services. The purporse is do not impact the cluster autoscaling by accidentally deploying many services of the type load balancer that would consume all IPs of the subnet.

- Because of naming standards, this module creates a managed identity that is used to integrate the AKS with other Azure services such as VNETs. All needed privileges to deploy the cluster are granted on the module. 

### [locals.tf](locals.tf)

You can update the locals.tf following these considerations:

- Some companies use a Hub/Spoke network topology, then following a MSFT recommendation, this module uses a single private dns zone aiming to have a single point of configuration. This private DNS zone usually is placed in the Hub subscription. 

- You can define your own default tags

## Use case

```hcl
module "<cluster-name>" {
  source = "git::https://github.com/danilomnds/terraform-azurerm-aks?ref=v2.1.0"
  name = "<cluster-name>"
  location = "<your-region>"
  resource_group_name = "<resource-group>"
  vnet_subnet_id_services = ["/subscriptions/<aks subscription>/resourceGroups/<aks resource group>/providers/Microsoft.Network/virtualNetworks/<aks vnet>/subnets/<aks node subnet>"]
  default_node_pool = {
    name = "npsystem1"
    vm_size = "Standard_D2as_v5"
    # renamed var on azurerm 4.x
    auto_scaling_enabled = true
    vnet_subnet_id = "/subscriptions/<aks subscription>/resourceGroups/<aks resource group>/providers/Microsoft.Network/virtualNetworks/<aks vnet>/subnets/<aks node subnet>"
    # example of customizing some kernel parameters (this is optional)
    linux_os_config = {
      swap_file_size_mb = <value>
      sysctl_config = {
        vm_max_map_count = <value>
      }
    }
    min_count = 3
    max_count = 6  
    only_critical_addons_enabled = "false"
    os_disk_size_gb = 128
  }
  http_application_routing_enabled = true
  kubernetes_version = "1.32.2"
  sku_tier = "Free"
  # attention! case sensive value
  oms_agent = {
    log_analytics_workspace_id = "/subscriptions/<id da subscription>/resourceGroups/<resource group>/providers/Microsoft.OperationalInsights/workspaces/<workspace>"
  }
}
output "cluster_name" {
  value = module.<cluster-name>.cluster_name
}
output "resource_group_name" {
  value = module.<cluster-name>.resource_group_name
}
output "node_resource_group" {
  value = module.<cluster-name>.node_resource_group
}
output "id" {
  value = module.<cluster-name>.id
}
output "host" {
  value = module.<cluster-name>.host
  sensitive = true
}
output "client_certificate" {
  value = module.<cluster-name>.client_certificate
  sensitive = true
}
output "client_key" {
  value = module.<cluster-name>.client_key
  sensitive = true
}
output "cluster_ca_certificate" {
  value = module.<cluster-name>.cluster_ca_certificate
  sensitive = true
}
```

## Input variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | cluster name | `string` | n/a | `Yes` |
| location | azure region | `string` | n/a | `Yes` |
| resource_group_name | resource group name where the AKS will be placed | `string` | n/a | `Yes` |
| vnet_subnet_id_service | subnet id that will host the services | `string` | n/a | `Yes` |
| default_node_pool | block as defined in the official documentation | `object(map(string))` | n/a | `Yes` |
| zones | specifies the default zones that will be used. If you need to undefine, set the value [] | `list` | `[1,2,3]` | No |
| dns_prefix | DNS prefix specified when creating the managed cluster | `string` | n/a | No |
| dns_prefix_private_cluster | Specifies the DNS prefix to use with private clusters | `string` | n/a | No |
| aci_connector_linux | block as defined in the official documentation | `object(map(string))` | n/a | No |
| automatic_upgrade_channel | the upgrade channel for this kubernetes cluster | `string` | n/a | No |
| api_server_access_profile | block as defined in the official documentation | `object(map(string))` | n/a | No |
| auto_scaler_profile | block as defined in the official documentation | `object(map(string))` | n/a | No |
| azure_active_directory_role_based_access_control | block as defined in the official documentation | `object(map(string))` | n/a | No |
| azure_policy_enabled | should the azure policy add-on be enabled?  | `bool` | `false` | No |
| confidential_computing | block as defined in the official documentation | `object(map(string))` | n/a | No |
| cost_analysis_enabled | should cost analysis be enabled for this kubernetes cluster? | `bool` | `false` | No |
| custom_ca_trust_certificates_base64 | a list of up to 10 base64 encoded cas that will be added to the trust store on nodes with the custom_ca_trust_enabled feature enabled | `list(string)` | n/a | No |
| disk_encryption_set_id | the id of the disk encryption set which should be used for the nodes and volumes | `string` | n/a | No |
| edge_zone | specifies the edge zone within the azure region where this managed kubernetes cluster should exist | `string` | n/a | No |
| http_application_routing_enabled | should http application routing be enabled? | `bool` | `false` | No |
| http_proxy_config | block as defined in the official documentation | `object(map(string))` | n/a | No |
| identity | block as defined in the official documentation | `object(map(string))` | n/a | No |
| image_cleaner_enabled | specifies whether image cleaner is enabled | `bool` | `true` | No |
| image_cleaner_interval_hours | Specifies the interval in hours when images should be cleaned up | `number` | `48` | No |
| ingress_application_gateway | block as defined in the official documentation | `object(map(string))` | n/a | No |
| key_management_service | block as defined in the official documentation | `object(map(string))` | n/a | No |
| key_vault_secrets_provider | block as defined in the official documentation | `object(map(string))` | n/a | No |
| kubelet_identity | block as defined in the official documentation | `object(map(string))` | n/a | No |
| kubernetes_version | kubernetes version | `string` | `latest recommended version` | No |
| linux_profile | block as defined in the official documentation | `object(map(string))` | n/a | No |
| key_data | the public ssh key used to access the cluster | `string(sensitive)` | n/a | No |
| local_account_disabled | if true local accounts will be disabled | `bool` | `false` | No |
| maintenance_window | block as defined in the official documentation | `object(map(string))` | n/a | No |
| maintenance_window_auto_upgrade | block as defined in the official documentation | `object(map(string))` | n/a | No |
| maintenance_window_node_os | block as defined in the official documentation | `object(map(string))` | n/a | No |
| microsoft_defender | block as defined in the official documentation | `object(map(string))` | n/a | No |
| monitor_metrics | block as defined in the official documentation | `object(map(string))` | n/a | No |
| network_profile | block as defined in the official documentation | `object(map(string))` | n/a | No |
| node_os_upgrade_channel | the upgrade channel for this kubernetes cluster nodes os image | `string` | n/a | No |
| node_resource_group | the name of the resource group where the kubernetes nodes should exist | `string` | n/a | No |
| oidc_issuer_enabled | Enable or Disable the OIDC issuer URL | `bool` | `false` | No |
| oms_agent | block as defined in the official documentation | `object(map(string))` | n/a | No |
| open_service_mesh_enabled | is open service mesh enabled | `bool` | `false` | No |
| private_cluster_enabled | should this kubernetes cluster have its api server only exposed on internal ip addresses? | `bool` | `true` | No |
| private_dns_zone_id | either the id of private dns zone which should be delegated to this cluster, system to have aks manage this or none | `string` | n/a | No |
| private_cluster_public_fqdn_enabled | specifies whether a public fqdn for this private cluster should be added | `bool` | `false` | No |
| service_mesh_profile | block as defined in the official documentation | `object(map(string))` | n/a | No |
| workload_autoscaler_profile | block as defined in the official documentation | `object(map(string))` | n/a | No |
| workload_identity_enabled | specifies whether azure ad workload identity should be enabled for the cluster | `bool` | `false` | No |
| public_network_access_enabled | whether public network access is allowed for this kubernetes cluster | `bool` | `true` | No |
| role_based_access_control_enabled | whether role based access control for the kubernetes cluster should be enabled | `bool` | `true` | No |
| run_command_enabled | whether to enable run command for the cluster or not | `bool` | `true` | No |
| service_principal | block as defined in the official documentation | `object(map(string))` | n/a | No |
| client_secret | the service principal's secret | `string(sensitive)` | n/a | No |
| sku_tier | the sku tier that should be used for this kubernetes cluster | `string` | `Free`| No |
| storage_profile | block as defined in the official documentation | `object(map(string))` | n/a | No |
| support_plan | specifies the support plan which should be used for this kubernetes cluster | `string` | `KubernetesOfficial` | No |
| tags | tags for the aks cluster | `map(string)` | `{}` | No |
| upgrade_override | block as defined in the official documentation | `object(map(string))` | n/a | No |
| web_app_routing | block as defined in the official documentation | `object(map(string))` | n/a | No |
| windows_profile | block as defined in the official documentation | `object(map(string))` | n/a | No |
| admin_password | admin password for the windows profile | `string(sensitive)` | n/a | No |
| azure_ad_groups_lock_contributor | groups that will have permissions to manage locks on aks resource group | `list(string)` | `L Group` | No |


## Output variables

| Name | Description |
|------|-------------|
| cluster_name | cluster name |
| resource_group_name | rg where the cluster was placed |
| node_resource_group | rg where the cluster resources were placed (lb, vmss etc) |
| id | cluster id |
| host | The Kubernetes cluster server host |
| client_certificate | Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster |
| client_key | Base64 encoded private key used by clients to authenticate to the Kubernetes cluster |
| cluster_ca_certificate | Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster |

## Documentation

Terraform Azure Kubernetes Services: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)<br>
Pods Limit on Kubenet Cluster: <br>
[https://docs.microsoft.com/en-us/azure/aks/configure-kubenet](https://docs.microsoft.com/en-us/azure/aks/configure-kubenet)<br>
Ephemeral disks: <br>
[https://docs.microsoft.com/en-us/azure/aks/cluster-configuration](https://docs.microsoft.com/en-us/azure/aks/cluster-configuration)<br>