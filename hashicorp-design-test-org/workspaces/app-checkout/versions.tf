terraform {
  cloud {
    organization = "hashicorp-design-test-org"
    workspaces {
      name = "hcp-design-app-checkout"
    }
  }
}
