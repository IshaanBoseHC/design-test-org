locals {
  tags = {
    team        = var.team
    environment = var.environment
    service     = var.service
    cost_center = var.cost_center
    managed_by  = "hcp-terraform"
  }
}
