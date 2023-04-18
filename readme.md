# Module - Azure Kubernetes Services (AKS)
[![COE](https://img.shields.io/badge/Created%20By-CCoE-blue)]()
[![HCL](https://img.shields.io/badge/language-HCL-blueviolet)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/provider-Azure-blue)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

Module developed to standardize the AKS creation.

## Compatibility Matrix

| Module Version | Terraform Version | AzureRM Version |
|----------------|-------------------| --------------- |
| v1.0.0         | v1.4.5            | 3.52.0         |

## Specifying a version

To avoid that your code get updates automatically, is mandatory to set the version using the `source` option. 
By defining the `?ref=***` in the the URL, you can define the version of the module.

Note: The `?ref=***` refers a tag on the git module repo.

## Important considerations

- Following a MSFT recommendation, this module needs two subnets. One for nodepools the other one for services. The purporse is do not impact the cluster autoscaling, for example by accidentally deploying many services of the type load balancing and consume all IPs of the subnet.

- Because of naming standards, this module creates a managed identity that is used to integrate the AKS with other Azure services such as VNETs. All needed privileges to deploy the cluster are granted on the module. 

- This module by default integrates the AKS with Azure AD and Azure Key Vault.


### [locals.tf](locals.tf)

You can update the locals.tf following these considerations:

- Some companies use a Hub/Spoke network topology, then following a MSFT recommendation, this module uses a single private dns zone in order to have a single point of configuration. This private DNS zone usually is placed in the Hub subscription. 

- You can define your own default tags

### [variables.tf](variables.tf)

You can edit this file in order to reflect your patterns. 

## Use case

```hcl
module "<cluster-name>" {
  source = "git::https://github.com/danilomnds/terraform-azurerm-aks?ref=v1.0.0"
  name = "<cluster-name>"
  location = "<your-region>"
  resource_group_name = "<resource-group>"
  kubernetes_version = "1.24.9"
  sku_tier = "Free"
  node_pool_name = "npsystem1"
  min_count = 3
  max_count = 6  
  vm_size = "Standard_D2s_v3"
  node_labels = {
    key1 = value1
    key2 = value2
  }
  only_critical_addons_enabled = "false"
  vnet_subnet_id_nodes = "/subscriptions/<aks subscription>/resourceGroups/<aks resource group>/providers/Microsoft.Network/virtualNetworks/<aks vnet>/subnets/<aks node subnet>"
  # you can specify more than one subnet that will be used for services or for a different nodepool
  vnet_subnet_id_services = ["/subscriptions/<aks subscription>/resourceGroups/<aks resource group>/providers/Microsoft.Network/virtualNetworks/<aks vnet>/subnets/<aks node subnet>"]
  os_disk_size_gb = 64
  nodepool_adv_config = {
    linux_os_config = {
      # example of customizing some kernel parameters
      swap_file_size_mb = <value>
      sysctl_config = { 
        vm_max_map_count = <value>
        net_ipv4_neigh_default_gc_thresh3 = <value>}
    }
  }
  # attention! case sensive value
  log_analytics_workspace_id = "/subscriptions/<id da subscription>/resourceGroups/<resource group>/providers/Microsoft.OperationalInsights/workspaces/<workspace>"
  tags = {
    key1 = "value1"
    key2 = "value2"    
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
| private_cluster_enabled | cluster API public? yes or no | `bool` | `true` | No |
| private_dns_zone_id | private dns zone where a cluster cname will be registered for private clusters | `string` | n/a | No |
| kubernetes_version | kubernetes version | `string` | `latest recommended version` | No |
| sku_tier | Free ou Paid | `string` | `Free` | No |
| node_pool_name | nodepool name | `string ` | n/a | `Yes` |
| enable_auto_scaling | nodepool autoscaling | `bool` | `true` | No |
| min_count | minimum number of nodes when autoscaling=true | `number` | n/a | No |
| max_count | maximum number of nodes when autoscaling=true | `number` | n/a | No |
| node_count | initial number of nodes. Must be defined when autoscaling=no | `number` | n/a | No |
| only_critical_addons_enabled | only system daemon sets will run on the nodepool | `bool` | `true` | No |
| node_labels | nodepool labels | `map` | n/a | No |
| vm_size | nodepool shape | `string` | n/a | `Yes` |
| vnet_subnet_id_nodes | subnet id to host the nodes | `string` | n/a | `Yes` |
| vnet_subnet_id_service | subnet id that will host the services | `string` | n/a | `Yes` |
| max_pods | maximum number of pods of a node | `number` | `110` | No |
| os_disk_type | type of the operating system disk | `string` | `Managed` | No |
| os_disk_size_gb | sizing of the operating system disk | `number` | n/a | `Yes` |
| zones | list of availabilty zones that will be used | `number` | `["1","2","3"]` | No |
| tags | tags for the aks cluster | `map(string)` | `{}` | No |
| nodepool_adv_config | used to define custom kernel parameters | `any` | n/a | No |
| log_analytics_workspace_id | used to enable the use of log analytics | `string` | n/a | No |
| load_balancer_sku | public loadbalancer sku | `string` | `standard` | No |
| network_plugin | Network plugin used by the cluster | `string` | `kubenet` | No |
| pod_cidr | must be defined only when network_plugin=kubelet | `string` | `172.27.0.0/16` | No |
| service_cidr | range used by kubernetes services | `string` | `172.28.0.0/16` | No |
| dns_service_ip | IP in the service_cidr that will be used by the kube-dns | `string` | `172.28.0.10` | No |
| network_policy | network policy used by the cluster | `string` | `calico` | No |
| outbound_type | outbound type of the cluster | `string` | `userDefinedRouting` | No |
| admin_group_object_ids | list of Azure AD groups that will manage the cluster | `list()` | n/a | No |
| admin_username | name for the cluster admin user | `string` | `aksadmin` | No |
| key_data | the public ssh key used to access the cluster | `string` | n/a | `Yes` |

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