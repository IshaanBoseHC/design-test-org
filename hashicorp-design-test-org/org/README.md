# Org Bootstrap (HCP Terraform)

This folder uses the `tfe` provider to create a fully fledged org structure:

- Projects for shared services, apps, data, and security
- Workspaces (backed by this repo) using VCS-driven runs
- Policy sets (Sentinel placeholder policies)
- Teams and access bindings

Apply this configuration once you have an organization and VCS connection
configured. Workspace configurations live in `workspaces/` and are referenced
from the `tfe_workspace` resources here.

## Variables

Set values in `org/variables.tf` for your org, VCS repo, and OAuth token.

## UI-only tasks

- Create the org and invite users
- Connect VCS and obtain the OAuth token ID
- Publish private modules in the registry
- Configure run task integrations

See `org/README-ui.md` for the detailed checklist.
