variable "service_name" {
  type        = string
  description = "Service name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "network_id" {
  type        = string
  description = "Network identifier"
}

variable "logging_id" {
  type        = string
  description = "Logging identifier"
}

variable "identity_id" {
  type        = string
  description = "Identity identifier"
}

variable "tags" {
  type        = map(string)
  description = "Standard tags"
  default     = {}
}
