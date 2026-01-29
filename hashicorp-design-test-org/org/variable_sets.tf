resource "tfe_variable_set" "global" {
  organization = var.organization
  name         = "Global Standards"
  description  = "Global tags and metadata for all workspaces"
}

resource "tfe_variable" "global_cost_center" {
  key             = "global_cost_center"
  value           = "cc-0000"
  category        = "terraform"
  description     = "Default cost center"
  variable_set_id = tfe_variable_set.global.id
}

resource "tfe_variable" "global_owner" {
  key             = "global_owner"
  value           = "design-platform"
  category        = "terraform"
  description     = "Global owner label"
  variable_set_id = tfe_variable_set.global.id
}

resource "tfe_variable" "registry_namespace" {
  key             = "registry_namespace"
  value           = var.registry_namespace
  category        = "terraform"
  description     = "Private registry namespace"
  variable_set_id = tfe_variable_set.global.id
}

resource "tfe_workspace_variable_set" "global_bindings" {
  for_each = tfe_workspace.workspaces

  variable_set_id = tfe_variable_set.global.id
  workspace_id    = each.value.id
}
