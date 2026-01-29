variable "environment" {
  type        = string
  description = "Environment name"
}

variable "region" {
  type        = string
  description = "Primary region"
}

variable "cidr" {
  type        = string
  description = "CIDR block for the network"
}

variable "tags" {
  type        = map(string)
  description = "Standard tags"
  default     = {}
}
