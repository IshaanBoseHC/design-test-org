terraform {
  required_version = ">= 1.5.0"
}

module "tags" {
  source      = "app.terraform.io/${var.registry_namespace}/tags/terraform"
  team        = "platform"
  environment = var.environment
  service     = "logging"
  cost_center = "cc-1002"
}

module "logging" {
  source         = "app.terraform.io/${var.registry_namespace}/logging/terraform"
  environment    = var.environment
  retention_days = var.retention_days
  destinations   = var.destinations
  tags           = module.tags.tags
}
