# Test file for network module

run "basic_network" {
  command = apply

  variables {
    environment = "dev"
    region      = "us-east-1"
    cidr        = "10.0.0.0/16"
    tags        = {
      team = "platform"
    }
  }

  assert {
    condition     = output.network_id == "net-dev-useast1"
    error_message = "Network ID should be 'net-dev-useast1'"
  }

  assert {
    condition     = output.cidr == "10.0.0.0/16"
    error_message = "CIDR should be '10.0.0.0/16'"
  }
}

run "production_network" {
  command = apply

  variables {
    environment = "prod"
    region      = "us-west-2"
    cidr        = "10.1.0.0/16"
    tags        = {
      team        = "platform"
      environment = "prod"
    }
  }

  assert {
    condition     = output.network_id == "net-prod-uswest2"
    error_message = "Network ID should be 'net-prod-uswest2'"
  }

  assert {
    condition     = output.cidr == "10.1.0.0/16"
    error_message = "CIDR should be '10.1.0.0/16'"
  }
}

run "multi_region_network" {
  command = apply

  variables {
    environment = "staging"
    region      = "eu-central-1"
    cidr        = "10.2.0.0/16"
    tags        = {}
  }

  assert {
    condition     = output.network_id == "net-staging-eucentral1"
    error_message = "Network ID should correctly format multi-dash region"
  }

  assert {
    condition     = output.cidr == "10.2.0.0/16"
    error_message = "CIDR should match input"
  }
}

run "network_id_format" {
  command = apply

  variables {
    environment = "dev"
    region      = "ap-southeast-1"
    cidr        = "192.168.0.0/16"
    tags        = {}
  }

  assert {
    condition     = can(regex("^net-[a-z]+-[a-z0-9]+$", output.network_id))
    error_message = "Network ID should follow the pattern 'net-{env}-{region}' with dashes removed from region"
  }
}
