variable "environment" {
  type        = string
  description = "Environment name"
}

variable "identity_provider" {
  type        = string
  description = "Primary identity provider"
}

variable "groups" {
  type        = list(string)
  description = "Identity groups"
}

variable "tags" {
  type        = map(string)
  description = "Standard tags"
  default     = {}
}
