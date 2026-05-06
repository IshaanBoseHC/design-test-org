terraform {
  required_providers {
    terraform = {
      source  = "hashicorp/terraform"
      version = ">= 1.5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
}
