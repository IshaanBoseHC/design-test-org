terraform {
  required_version = ">= 1.5.0"
}

module "tags" {
  source      = "app.terraform.io/${var.registry_namespace}/tags/terraform"
  team        = "platform"
  environment = var.environment
  service     = "identity"
  cost_center = "cc-1003"
}

module "identity" {
  source            = "app.terraform.io/${var.registry_namespace}/identity/terraform"
  environment       = var.environment
  identity_provider = var.identity_provider
  groups            = var.groups
  tags              = module.tags.tags
}
