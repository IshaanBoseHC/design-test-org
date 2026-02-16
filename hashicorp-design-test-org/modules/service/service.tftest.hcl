# Test file for service module

run "basic_service" {
  command = plan

  variables {
    service_name = "checkout"
    environment  = "dev"
    network_id   = "net-dev-useast1"
    logging_id   = "log-dev"
    identity_id  = "id-dev"
    tags         = {
      team = "app"
    }
  }

  assert {
    condition     = output.service_id == "svc-dev-checkout"
    error_message = "Service ID should be 'svc-dev-checkout'"
  }
}

run "production_service" {
  command = plan

  variables {
    service_name = "billing"
    environment  = "prod"
    network_id   = "net-prod-uswest2"
    logging_id   = "log-prod"
    identity_id  = "id-prod"
    tags         = {
      team        = "app"
      environment = "prod"
      critical    = "true"
    }
  }

  assert {
    condition     = output.service_id == "svc-prod-billing"
    error_message = "Service ID should be 'svc-prod-billing'"
  }
}

run "staging_service" {
  command = plan

  variables {
    service_name = "analytics"
    environment  = "staging"
    network_id   = "net-staging-eucentral1"
    logging_id   = "log-staging"
    identity_id  = "id-staging"
    tags         = {}
  }

  assert {
    condition     = output.service_id == "svc-staging-analytics"
    error_message = "Service ID should be 'svc-staging-analytics'"
  }
}

run "service_with_dependencies" {
  command = plan

  variables {
    service_name = "payment"
    environment  = "dev"
    network_id   = "net-dev-useast1"
    logging_id   = "log-dev"
    identity_id  = "id-dev"
    tags         = {
      team     = "fintech"
      pci_dss  = "true"
      critical = "true"
    }
  }

  assert {
    condition     = output.service_id == "svc-dev-payment"
    error_message = "Service ID should correctly combine environment and service name"
  }
}

run "service_id_format" {
  command = plan

  variables {
    service_name = "test-service"
    environment  = "dev"
    network_id   = "net-123"
    logging_id   = "log-123"
    identity_id  = "id-123"
    tags         = {}
  }

  assert {
    condition     = can(regex("^svc-[a-z]+-[a-z-]+$", output.service_id))
    error_message = "Service ID should follow the pattern 'svc-{environment}-{service_name}'"
  }
}
