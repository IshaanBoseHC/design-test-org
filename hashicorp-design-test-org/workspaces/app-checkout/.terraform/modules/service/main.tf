resource "terraform_data" "service" {
  input = {
    name        = var.service_name
    environment = var.environment
    network_id  = var.network_id
    logging_id  = var.logging_id
    identity_id = var.identity_id
    tags        = var.tags
  }
}
