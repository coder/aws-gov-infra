################################################################################
# aws-gov-infra — Additional Data Resources
# Deploys OpenSearch, SES, and S3 buckets that are NOT required for Coder.
# Consumes coder4gov Layer 1 (network) and Layer 2 (data) remote state.
################################################################################

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket            = "coder4gov-terraform-state"
    key               = "aws-gov-infra/data/terraform.tfstate"
    region            = "us-west-2"
    encrypt           = true
    dynamodb_table    = "coder4gov-terraform-lock"
    use_fips_endpoint = true
  }
}

provider "aws" {
  region            = var.aws_region
  use_fips_endpoint = var.use_fips_endpoints

  default_tags {
    tags = var.tags
  }
}

# Remote state — coder4gov Layer 1 (Network)
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket            = "coder4gov-terraform-state"
    key               = "1-network/terraform.tfstate"
    region            = var.aws_region
    encrypt           = true
    use_fips_endpoint = true
  }
}

# Remote state — coder4gov Layer 2 (Data)
data "terraform_remote_state" "data" {
  backend = "s3"
  config = {
    bucket            = "coder4gov-terraform-state"
    key               = "2-data/terraform.tfstate"
    region            = var.aws_region
    encrypt           = true
    use_fips_endpoint = true
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr           = data.terraform_remote_state.network.outputs.vpc_cidr
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  route53_zone_id    = data.terraform_remote_state.network.outputs.route53_zone_id
  kms_key_arn        = data.terraform_remote_state.data.outputs.kms_key_arn
}
