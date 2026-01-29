# HCP Terraform Design Test Org (Monorepo)

This repo bootstraps a realistic HCP Terraform organization for visual testing and
pattern exploration. It includes a Terraform Cloud admin configuration, shared
modules, workspace configurations, and illustrative stacks.

## Repository layout

- `org/` - HCP Terraform org admin config (projects, workspaces, policy sets, teams)
- `modules/` - reusable modules that power workspace configs
- `workspaces/` - workspace Terraform configurations (shared + app + data)
- `stacks/` - illustrative stack definitions for environment orchestration

## Quick start

1. Create or select an HCP Terraform org in the UI (required for initial access).
2. Create an API token and export it as `TFE_TOKEN`.
3. From `org/`, run `terraform init` then `terraform apply` to create projects,
   workspaces, policy sets, and teams.
4. Connect your VCS repo and configure the `vcs_repo_identifier` and
   `vcs_oauth_token_id` variables.
5. Review each workspace config in `workspaces/` and run plans from HCP Terraform.

## UI-only steps (cannot be fully automated)

- Create the initial HCP Terraform organization and invite users.
- Connect VCS provider and authorize OAuth (token ID used in `org/variables.tf`).
- Publish private modules in the registry and map them to module directories.
- Configure run task integrations (e.g., Infracost, Checkov, Wiz).
- Create Stack deployments for environments (see `stacks/README.md`).

## Suggested workflow

- Start with `org/README.md` to understand org-level resources.
- Apply `org/` to create workspaces and policies.
- Iterate inside `workspaces/` for individual stacks and app services.
