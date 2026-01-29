variable "environment" {
  type        = string
  description = "Environment name"
}

variable "retention_days" {
  type        = number
  description = "Log retention in days"
}

variable "destinations" {
  type        = list(string)
  description = "Logging destinations"
}

variable "tags" {
  type        = map(string)
  description = "Standard tags"
  default     = {}
}
