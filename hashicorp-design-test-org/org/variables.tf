variable "tfe_hostname" {
  type        = string
  description = "HCP Terraform hostname"
  default     = "app.terraform.io"
}

variable "tfe_token" {
  type        = string
  description = "TFE API token"
  sensitive   = true
}

variable "organization" {
  type        = string
  description = "HCP Terraform organization name"
}

variable "vcs_repo_identifier" {
  type        = string
  description = "VCS repo identifier, e.g. org/repo"
  default     = null
}

variable "vcs_oauth_token_id" {
  type        = string
  description = "OAuth token ID from VCS connection"
  default     = null
}

variable "enable_registry_modules" {
  type        = bool
  description = "Whether to create private registry modules"
  default     = false
}

variable "registry_namespace" {
  type        = string
  description = "Namespace used for private registry modules"
  default     = "hashicorp-design"
}

variable "workspace_prefix" {
  type        = string
  description = "Prefix for workspace names"
  default     = "hcp-design"
}
