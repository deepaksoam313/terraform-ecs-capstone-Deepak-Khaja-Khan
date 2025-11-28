###############################
# Terraform Settings
###############################
terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {}
}

###############################
# Provider
###############################
provider "aws" {
  region = var.region
}
