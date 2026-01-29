resource "tfe_registry_module" "modules" {
  for_each = var.enable_registry_modules ? {
    network  = "modules/network"
    logging  = "modules/logging"
    identity = "modules/identity"
    service  = "modules/service"
    tags     = "modules/tags"
  } : {}

  organization = var.organization

  vcs_repo {
    identifier         = var.vcs_repo_identifier
    display_identifier = var.vcs_repo_identifier
    oauth_token_id     = var.vcs_oauth_token_id
    branch             = "main"
    source_directory   = each.value
  }
}
