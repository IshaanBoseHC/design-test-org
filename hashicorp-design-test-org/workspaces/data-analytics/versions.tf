terraform {
  required_providers {
    terraform = {
      source  = "hashicorp/terraform"
      version = ">= 1.5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}
