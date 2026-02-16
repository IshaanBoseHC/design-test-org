# Test file for identity module

run "basic_identity" {
  command = plan

  variables {
    environment       = "dev"
    identity_provider = "okta"
    groups            = ["developers", "operators"]
    tags              = {
      team = "platform"
    }
  }

  assert {
    condition     = output.identity_id == "id-dev"
    error_message = "Identity ID should be 'id-dev'"
  }
}

run "production_identity" {
  command = plan

  variables {
    environment       = "prod"
    identity_provider = "azure-ad"
    groups            = ["admins", "engineers", "security"]
    tags              = {
      team        = "platform"
      environment = "prod"
    }
  }

  assert {
    condition     = output.identity_id == "id-prod"
    error_message = "Identity ID should be 'id-prod'"
  }
}

run "staging_identity" {
  command = plan

  variables {
    environment       = "staging"
    identity_provider = "google"
    groups            = ["testers"]
    tags              = {}
  }

  assert {
    condition     = output.identity_id == "id-staging"
    error_message = "Identity ID should be 'id-staging'"
  }
}

run "identity_with_multiple_groups" {
  command = plan

  variables {
    environment       = "dev"
    identity_provider = "auth0"
    groups            = ["group1", "group2", "group3", "group4"]
    tags              = {}
  }

  assert {
    condition     = output.identity_id == "id-dev"
    error_message = "Identity ID should be based on environment"
  }
}

run "identity_id_format" {
  command = plan

  variables {
    environment       = "test"
    identity_provider = "okta"
    groups            = ["testgroup"]
    tags              = {}
  }

  assert {
    condition     = can(regex("^id-[a-z]+$", output.identity_id))
    error_message = "Identity ID should follow the pattern 'id-{environment}'"
  }
}
