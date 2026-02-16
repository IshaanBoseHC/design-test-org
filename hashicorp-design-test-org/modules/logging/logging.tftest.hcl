# Test file for logging module

run "basic_logging" {
  command = plan

  variables {
    environment    = "dev"
    retention_days = 30
    destinations   = ["s3", "cloudwatch"]
    tags           = {
      team = "platform"
    }
  }

  assert {
    condition     = output.logging_id == "log-dev"
    error_message = "Logging ID should be 'log-dev'"
  }
}

run "production_logging" {
  command = plan

  variables {
    environment    = "prod"
    retention_days = 90
    destinations   = ["s3", "cloudwatch", "splunk"]
    tags           = {
      team        = "platform"
      environment = "prod"
    }
  }

  assert {
    condition     = output.logging_id == "log-prod"
    error_message = "Logging ID should be 'log-prod'"
  }
}

run "long_retention" {
  command = plan

  variables {
    environment    = "prod"
    retention_days = 365
    destinations   = ["s3"]
    tags           = {}
  }

  assert {
    condition     = output.logging_id == "log-prod"
    error_message = "Logging ID should be based on environment"
  }
}

run "staging_logging" {
  command = plan

  variables {
    environment    = "staging"
    retention_days = 60
    destinations   = ["cloudwatch"]
    tags           = {
      environment = "staging"
    }
  }

  assert {
    condition     = output.logging_id == "log-staging"
    error_message = "Logging ID should be 'log-staging'"
  }
}

run "logging_id_format" {
  command = plan

  variables {
    environment    = "dev"
    retention_days = 7
    destinations   = ["stdout"]
    tags           = {}
  }

  assert {
    condition     = can(regex("^log-[a-z]+$", output.logging_id))
    error_message = "Logging ID should follow the pattern 'log-{environment}'"
  }
}
