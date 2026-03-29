################################################################################
# aws-gov-infra — Platform Services
# Deploys Istio, WAF, FluxCD bootstrap on top of coder4gov EKS cluster.
# Consumes coder4gov Layers 1–4 remote state.
################################################################################

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket            = "coder4gov-terraform-state"
    key               = "aws-gov-infra/platform/terraform.tfstate"
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

# Remote state — coder4gov Layer 3 (EKS)
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket            = "coder4gov-terraform-state"
    key               = "3-eks/terraform.tfstate"
    region            = var.aws_region
    encrypt           = true
    use_fips_endpoint = true
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name, "--region", var.aws_region]
  }
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name, "--region", var.aws_region]
    }
  }
}

provider "kubectl" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name, "--region", var.aws_region]
  }
}
