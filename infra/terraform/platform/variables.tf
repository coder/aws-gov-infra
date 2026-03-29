variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-west-2"
}

variable "use_fips_endpoints" {
  description = "Whether to use FIPS-validated endpoints."
  type        = bool
  default     = true
}

variable "project_name" {
  description = "Project slug."
  type        = string
  default     = "coder4gov"
}

variable "tags" {
  description = "Default tags applied to all resources."
  type        = map(string)
  default = {
    Project     = "coder4gov"
    ManagedBy   = "terraform"
    Environment = "production"
    Repo        = "aws-gov-infra"
  }
}

variable "istio_version" {
  description = "Helm chart version for Istio."
  type        = string
  default     = "1.24.0"
}

variable "allowed_admin_cidrs" {
  description = "CIDR blocks allowed to access Keycloak /admin paths."
  type        = list(string)
  default     = []
}

variable "flux_bootstrap_enabled" {
  description = "Enable FluxCD bootstrap."
  type        = bool
  default     = false
}

variable "flux_git_url" {
  description = "Git repository URL for FluxCD."
  type        = string
  default     = ""
}

variable "flux_git_branch" {
  description = "Git branch for FluxCD."
  type        = string
  default     = "main"
}

variable "flux_git_token" {
  description = "Git token for FluxCD HTTPS auth."
  type        = string
  default     = ""
  sensitive   = true
}
