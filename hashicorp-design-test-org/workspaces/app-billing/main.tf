terraform {
  required_version = ">= 1.5.0"
}

module "tags" {
  source      = "app.terraform.io/hashicorp-design-test-org/tags/terraform"
  team        = "app"
  environment = var.environment
  service     = "billing"
  cost_center = "cc-2002"
}

module "service" {
  source       = "app.terraform.io/hashicorp-design-test-org/service/terraform"
  service_name = "billing"
  environment  = var.environment
  network_id   = var.network_id
  logging_id   = var.logging_id
  identity_id  = var.identity_id
  tags         = module.tags.tags
}
