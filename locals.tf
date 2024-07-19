locals {
  default_tags = {
    deployedby  = "Terraform"
    provider    = "azr"
    region      = replace(lower(var.location), " ", "")
    create_date = formatdate("DD/MM/YY hh:mm", timeadd(timestamp(), "-3h"))
  }
  tags   = merge(local.default_tags, var.tags)
  subnet = element(split("/", lookup(var.default_node_pool, "vnet_subnet_id", null)), length(split("/", lookup(var.default_node_pool, "vnet_subnet_id", null))) - 1)
  vnet   = element(split("/", lookup(var.default_node_pool, "vnet_subnet_id", null)), length(split("/", lookup(var.default_node_pool, "vnet_subnet_id", null))) - 3)
  rg     = element(split("/", lookup(var.default_node_pool, "vnet_subnet_id", null)), length(split("/", lookup(var.default_node_pool, "vnet_subnet_id", null))) - 7)
}