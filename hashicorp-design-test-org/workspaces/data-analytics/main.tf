terraform {
  required_version = ">= 1.5.0"
}

module "tags" {
  source      = "app.terraform.io/${var.registry_namespace}/tags/terraform"
  team        = "data"
  environment = var.environment
  service     = "analytics"
  cost_center = "cc-3001"
}

module "service" {
  source       = "app.terraform.io/${var.registry_namespace}/service/terraform"
  service_name = "analytics"
  environment  = var.environment
  network_id   = var.network_id
  logging_id   = var.logging_id
  identity_id  = var.identity_id
  tags         = module.tags.tags
}
