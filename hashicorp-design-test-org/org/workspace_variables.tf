resource "tfe_variable" "workspace_env" {
  for_each = tfe_workspace.workspaces

  key          = "workspace_name"
  value        = each.value.name
  category     = "terraform"
  description  = "Workspace name"
  workspace_id = each.value.id
}
