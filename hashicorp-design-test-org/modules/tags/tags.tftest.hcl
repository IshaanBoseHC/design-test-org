# Test file for tags module

run "basic_tags" {
  command = plan

  variables {
    team        = "platform"
    environment = "dev"
    service     = "test-service"
    cost_center = "cc-1001"
  }

  assert {
    condition     = output.tags["team"] == "platform"
    error_message = "Team tag should be 'platform'"
  }

  assert {
    condition     = output.tags["environment"] == "dev"
    error_message = "Environment tag should be 'dev'"
  }

  assert {
    condition     = output.tags["service"] == "test-service"
    error_message = "Service tag should be 'test-service'"
  }

  assert {
    condition     = output.tags["cost_center"] == "cc-1001"
    error_message = "Cost center tag should be 'cc-1001'"
  }

  assert {
    condition     = output.tags["managed_by"] == "hcp-terraform"
    error_message = "Managed by tag should be 'hcp-terraform'"
  }
}

run "production_tags" {
  command = plan

  variables {
    team        = "app"
    environment = "prod"
    service     = "billing"
    cost_center = "cc-2002"
  }

  assert {
    condition     = output.tags["team"] == "app"
    error_message = "Team tag should be 'app'"
  }

  assert {
    condition     = output.tags["environment"] == "prod"
    error_message = "Environment tag should be 'prod'"
  }

  assert {
    condition     = output.tags["service"] == "billing"
    error_message = "Service tag should be 'billing'"
  }

  assert {
    condition     = length(output.tags) == 5
    error_message = "Should have exactly 5 tags"
  }
}

run "staging_environment" {
  command = plan

  variables {
    team        = "data"
    environment = "staging"
    service     = "analytics"
    cost_center = "cc-3003"
  }

  assert {
    condition     = output.tags["environment"] == "staging"
    error_message = "Environment tag should be 'staging'"
  }

  assert {
    condition     = output.tags["team"] == "data"
    error_message = "Team tag should be 'data'"
  }

  assert {
    condition     = contains(keys(output.tags), "managed_by")
    error_message = "Tags should always include 'managed_by' key"
  }
}
