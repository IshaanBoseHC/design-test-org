locals {
  network_id = "net-${var.environment}-${replace(var.region, "-", "")}" 
}

resource "terraform_data" "network" {
  input = {
    id     = local.network_id
    region = var.region
    cidr   = var.cidr
    tags   = var.tags
  }
}
