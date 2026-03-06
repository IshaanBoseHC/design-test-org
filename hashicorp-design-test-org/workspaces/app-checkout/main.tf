terraform {
  required_version = ">= 1.5.0"
}

module "tags" {
  source      = "app.terraform.io/hashicorp-design-test-org/tags/test"
  team        = "app"
  environment = var.environment
  service     = "checkout"
  cost_center = "cc-2001"
  ishaan = "owner"
}

module "service" {
  source       = "app.terraform.io/hashicorp-design-test-org/service/test"
  service_name = "checkout"
  environment  = var.environment
  network_id   = var.network_id
  logging_id   = var.logging_id
  identity_id  = var.identity_id
  tags         = module.tags.tags
}
