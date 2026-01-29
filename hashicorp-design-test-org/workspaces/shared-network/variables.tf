variable "environment" {
  type        = string
  description = "Environment name"
  default     = "shared"
}

variable "registry_namespace" {
  type        = string
  description = "Private registry namespace"
  default     = "hashicorp-design"
}

variable "region" {
  type        = string
  description = "Primary region"
  default     = "us-west-2"
}

variable "cidr" {
  type        = string
  description = "Network CIDR"
  default     = "10.20.0.0/20"
}
