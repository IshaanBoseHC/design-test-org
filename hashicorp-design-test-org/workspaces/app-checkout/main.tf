terraform {
  required_version = ">= 1.5.0"
}

module "tags" {
  source      = "app.terraform.io/${var.registry_namespace}/tags/terraform"
  team        = "app"
  environment = var.environment
  service     = "checkout"
  cost_center = "cc-2001"
}

module "service" {
  source       = "app.terraform.io/${var.registry_namespace}/service/terraform"
  service_name = "checkout"
  environment  = var.environment
  network_id   = var.network_id
  logging_id   = var.logging_id
  identity_id  = var.identity_id
  tags         = module.tags.tags
}
