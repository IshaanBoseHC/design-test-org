terraform {
  required_version = ">= 1.5.0"
}

module "tags" {
  source      = "app.terraform.io/${var.registry_namespace}/tags/terraform"
  team        = "security"
  environment = var.environment
  service     = "baseline"
  cost_center = "cc-4001"
}

resource "terraform_data" "baseline" {
  input = {
    environment = var.environment
    controls    = var.controls
    tags        = module.tags.tags
  }
}
