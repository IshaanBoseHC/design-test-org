resource "terraform_data" "logging" {
  input = {
    environment  = var.environment
    retention    = var.retention_days
    destinations = var.destinations
    tags         = var.tags
  }
}
