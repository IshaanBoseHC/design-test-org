output "project_ids" {
  description = "Project ids created for the org"
  value       = { for key, project in tfe_project.projects : key => project.id }
}

output "workspace_ids" {
  description = "Workspace ids created for the org"
  value       = { for key, workspace in tfe_workspace.workspaces : key => workspace.id }
}
