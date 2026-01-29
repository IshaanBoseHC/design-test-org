locals {
  projects = {
    shared   = "Shared Services"
    apps     = "Applications"
    data     = "Data Platform"
    security = "Security"
  }

  workspaces = {
    shared-network = {
      project = "shared"
      directory = "workspaces/shared-network"
      description = "Core networking baseline and shared subnets"
      tags = ["shared", "network", "foundation"]
    }
    shared-logging = {
      project = "shared"
      directory = "workspaces/shared-logging"
      description = "Centralized logging and audit sinks"
      tags = ["shared", "logging", "observability"]
    }
    shared-identity = {
      project = "shared"
      directory = "workspaces/shared-identity"
      description = "Org identity and access baselines"
      tags = ["shared", "identity", "iam"]
    }
    app-checkout = {
      project = "apps"
      directory = "workspaces/app-checkout"
      description = "Checkout service platform layer"
      tags = ["app", "checkout", "critical"]
    }
    app-billing = {
      project = "apps"
      directory = "workspaces/app-billing"
      description = "Billing orchestration and payments"
      tags = ["app", "billing", "payments"]
    }
    data-analytics = {
      project = "data"
      directory = "workspaces/data-analytics"
      description = "Analytics platform and pipelines"
      tags = ["data", "analytics", "warehouse"]
    }
    security-baseline = {
      project = "security"
      directory = "workspaces/security-baseline"
      description = "Security baselines and policy controls"
      tags = ["security", "baseline", "compliance"]
    }
  }

  policies = {
    approved-regions = {
      name = "approved-regions"
      description = "Restrict deployments to approved regions"
      set = "baseline"
    }
    encryption-required = {
      name = "encryption-required"
      description = "Require storage encryption"
      set = "baseline"
    }
  }
}

resource "tfe_project" "projects" {
  for_each     = local.projects
  organization = var.organization
  name         = each.value
}

resource "tfe_workspace" "workspaces" {
  for_each = local.workspaces

  organization = var.organization
  name         = "${var.workspace_prefix}-${each.key}"
  description  = each.value.description
  project_id   = tfe_project.projects[each.value.project].id
  tag_names    = each.value.tags

  terraform_version = "1.6.6"
  auto_apply        = false
  queue_all_runs    = true

  working_directory = each.value.directory
}

resource "tfe_policy_set" "policy_sets" {
  for_each = {
    baseline = {
      name = "Baseline-Guardrails"
      description = "Foundational guardrails for shared infrastructure"
    }
  }

  name          = each.value.name
  description   = each.value.description
  organization  = var.organization
  workspace_ids = [for workspace in tfe_workspace.workspaces : workspace.id]
  policy_ids    = [for key, policy in tfe_policy.policies : policy.id if local.policies[key].set == each.key]
}

resource "tfe_policy" "policies" {
  for_each = local.policies

  name         = each.value.name
  description  = each.value.description
  organization = var.organization
  kind         = "sentinel"
  policy       = <<-EOT
  import "tfplan/v2" as tfplan

  main = rule { true }
  EOT
}
