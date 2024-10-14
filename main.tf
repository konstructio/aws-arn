terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.71.0"
    }
  }
}

provider  "aws" {
  region = "us-east-1"
}

module "kubefirst-pro" {
    source          = "./modules/kubefirst-pro"
    oidc_endpoint   = var.oidc_endpoint
    cluster_name    = var.cluster_name  
}
