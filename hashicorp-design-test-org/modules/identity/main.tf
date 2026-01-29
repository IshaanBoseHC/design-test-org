resource "terraform_data" "identity" {
  input = {
    environment = var.environment
    provider    = var.identity_provider
    groups      = var.groups
    tags        = var.tags
  }
}
