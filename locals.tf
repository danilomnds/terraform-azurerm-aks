locals {
  zone_id = {
    "brazilsouth"      = "/subscriptions/<subscription id>/resourceGroups/<resource group>/providers/Microsoft.Network/privateDnsZones/<private dns zone>"
    "Brazil South"     = "/subscriptions/<subscription id>/resourceGroups/<resource group>/providers/Microsoft.Network/privateDnsZones/<private dns zone>"
    "brazilsoutheast"  = "/subscriptions/<subscription id>/resourceGroups/<resource group>/providers/Microsoft.Network/privateDnsZones/<private dns zone>"
    "Brazil Southeast" = "/subscriptions/<subscription id>/resourceGroups/<resource group>/providers/Microsoft.Network/privateDnsZones/<private dns zone>"
  }
  default_tags = {
    deployedby  = "Terraform"
    provider    = "azr"
    region      = replace(lower(var.location), " ", "")
    create_date = formatdate("DD/MM/YY hh:mm", timeadd(timestamp(), "-3h"))
    type        = "paas"
    resource    = "kubernetes"
    layer       = "application"
  }
  tags   = merge(local.default_tags, var.tags)
  subnet = element(split("/", var.vnet_subnet_id_nodes), length(split("/", var.vnet_subnet_id_nodes)) - 1)
  vnet   = element(split("/", var.vnet_subnet_id_nodes), length(split("/", var.vnet_subnet_id_nodes)) - 3)
  rg     = element(split("/", var.vnet_subnet_id_nodes), length(split("/", var.vnet_subnet_id_nodes)) - 7)
}