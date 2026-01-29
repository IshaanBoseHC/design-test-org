variable "environment" {
  default = "dev"
}

component "shared_network" {
  source  = "../workspaces/shared-network"
}

component "shared_logging" {
  source  = "../workspaces/shared-logging"
}

component "shared_identity" {
  source  = "../workspaces/shared-identity"
}

component "app_checkout" {
  source  = "../workspaces/app-checkout"
}

component "app_billing" {
  source  = "../workspaces/app-billing"
}

component "data_analytics" {
  source  = "../workspaces/data-analytics"
}
