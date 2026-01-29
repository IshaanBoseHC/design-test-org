terraform {
  required_version = ">= 1.5.0"
}

module "tags" {
  source      = "app.terraform.io/${var.registry_namespace}/tags/terraform"
  team        = "platform"
  environment = var.environment
  service     = "network"
  cost_center = "cc-1001"
}

module "network" {
  source      = "app.terraform.io/${var.registry_namespace}/network/terraform"
  environment = var.environment
  region      = var.region
  cidr        = var.cidr
  tags        = module.tags.tags
}
