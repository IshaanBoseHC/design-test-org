# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a monorepo for bootstrapping and managing an HCP Terraform organization with realistic infrastructure patterns. It demonstrates organization-level configuration management, reusable modules, workspace orchestration, and Terraform Stacks.

## Architecture

### Four-Layer Structure

1. **Organization Layer (`org/`)**: Uses the `tfe` provider to bootstrap the entire HCP Terraform organization infrastructure including projects, workspaces, policy sets, teams, and access controls. This is the foundation that creates all other resources.

2. **Module Layer (`modules/`)**: Contains source modules that define reusable infrastructure patterns:
   - `network/` - Networking primitives
   - `logging/` - Centralized logging infrastructure
   - `identity/` - IAM and identity baselines
   - `service/` - Generic service deployment patterns
   - `tags/` - Standardized tagging conventions

3. **Workspace Layer (`workspaces/`)**: Individual Terraform configurations organized by domain:
   - **Shared Services**: `shared-network`, `shared-logging`, `shared-identity` (foundation layer)
   - **Applications**: `app-checkout`, `app-billing` (depends on shared services)
   - **Data Platform**: `data-analytics`
   - **Security**: `security-baseline`

4. **Stack Layer (`stacks/`)**: Multi-workspace orchestration definitions that compose workspaces into environment deployments (`dev.hcl`, `staging.hcl`, `prod.hcl`).

### Key Architectural Patterns

- **Module Publishing**: Local modules in `modules/` are published to the HCP Terraform private registry and referenced by workspaces via registry paths (e.g., `app.terraform.io/hashicorp-design-test-org/tags/test`)
- **Dependency Flow**: Workspaces follow a dependency chain where shared infrastructure (network, logging, identity) must be deployed before application workspaces
- **Project Organization**: Resources are grouped into logical projects (Shared Services, Applications, Data Platform, Security) for access control and organization

## Common Commands

### Organization Bootstrap

```bash
# Set your HCP Terraform token
export TFE_TOKEN="your-token-here"

# Bootstrap the organization (creates projects, workspaces, policies)
cd org/
terraform init
terraform plan -var="organization=your-org-name"
terraform apply -var="organization=your-org-name"
```

### Working with Workspaces

```bash
# Initialize and plan a workspace
cd workspaces/shared-network/
terraform init
terraform plan

# Apply changes (typically done through HCP Terraform UI for VCS-driven runs)
terraform apply
```

### Validate Terraform Configurations

```bash
# Format all Terraform files
terraform fmt -recursive

# Validate configuration in a directory
cd workspaces/app-billing/
terraform init
terraform validate
```

## Development Workflow

### Initial Setup Order

1. **Prepare Organization**: Create the HCP Terraform organization in the UI, connect VCS, and obtain OAuth token ID
2. **Configure Variables**: Update `org/variables.tf` with your organization name, VCS repo identifier, and OAuth token ID
3. **Bootstrap Organization**: Apply the `org/` configuration to create all projects, workspaces, and policies
4. **Publish Modules**: Publish each module from `modules/` to the private registry via the HCP Terraform UI
5. **Deploy Shared Services**: Trigger runs for `shared-network`, `shared-logging`, and `shared-identity` workspaces (in that order)
6. **Deploy Applications**: After shared services are deployed, trigger runs for application and data workspaces

### Adding a New Workspace

1. Create directory under `workspaces/new-workspace-name/`
2. Add Terraform configuration referencing private registry modules
3. Add workspace definition to `org/main.tf` in the `local.workspaces` map
4. Apply the `org/` configuration to create the workspace in HCP Terraform
5. Add component to `stacks/stacks.hcl` if it should be included in stack deployments

### Modifying Modules

Modules in `modules/` are the source of truth. After making changes:
1. Commit changes to version control
2. Update the module version in the private registry (HCP Terraform UI)
3. Workspaces will automatically use the updated module on their next run

## Environment Variables

- `TFE_TOKEN`: API token for authenticating with HCP Terraform (required for `org/` operations)
- `TF_VAR_*`: Standard Terraform variable prefix for passing variables via environment

## Important Constraints

### UI-Only Operations

These cannot be fully automated and must be performed in the HCP Terraform UI:
- Creating the initial organization
- Connecting VCS providers and obtaining OAuth tokens
- Publishing modules to the private registry
- Creating Stack deployments
- Configuring run task integrations (Infracost, Checkov, etc.)

### Module References

Workspaces reference modules via private registry paths, not local paths. The format is:
```hcl
module "tags" {
  source = "app.terraform.io/<org-name>/tags/test"
  # ...
}
```

This means modules must be published to the registry before workspace runs will succeed.

### Workspace Execution

Workspaces are configured for VCS-driven runs in HCP Terraform. Local `terraform apply` commands in workspace directories will not have the same context as the HCP Terraform execution environment (different backend, variables, etc.).

## Project Structure Reference

```
.
├── org/                          # Organization bootstrap configuration
│   ├── main.tf                   # Projects, workspaces, policies
│   ├── providers.tf              # TFE provider configuration
│   ├── variables.tf              # Org-level variables
│   ├── variable_sets.tf          # Variable sets for workspaces
│   ├── workspace_variables.tf    # Per-workspace variable assignments
│   ├── registry_modules.tf       # Private registry module config
│   ├── run_tasks.tf              # Run task integrations
│   └── README-ui.md              # UI-only setup tasks
├── modules/                      # Source modules (published to registry)
│   ├── network/
│   ├── logging/
│   ├── identity/
│   ├── service/
│   └── tags/
├── workspaces/                   # Workspace Terraform configurations
│   ├── shared-network/
│   ├── shared-logging/
│   ├── shared-identity/
│   ├── app-checkout/
│   ├── app-billing/
│   ├── data-analytics/
│   └── security-baseline/
└── stacks/                       # Stack deployment definitions
    ├── stacks.hcl                # Component definitions
    ├── dev.hcl
    ├── staging.hcl
    └── prod.hcl
```

## Version Requirements

- Terraform >= 1.5.0
- TFE Provider >= 0.73.0
- Terraform version 1.6.6 is configured for all workspaces
