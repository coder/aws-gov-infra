variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-west-2"
}

variable "aws_partition" {
  description = "AWS partition (aws or aws-us-gov)."
  type        = string
  default     = "aws"
}

variable "project_name" {
  description = "Project slug used in naming and tagging."
  type        = string
  default     = "coder4gov"
}

variable "use_fips_endpoints" {
  description = "Whether to use FIPS-validated endpoints."
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Primary domain name."
  type        = string
  default     = "coder4gov.com"
}

variable "cloudtrail_log_group_name" {
  description = "CloudWatch log group name for CloudTrail logs (fed into OpenSearch)."
  type        = string
  default     = "/aws/cloudtrail/coder4gov"
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
