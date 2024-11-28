terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "= 2.16.1"
    }
  }
}

locals {
  env_name          = "sandbox"
  provisioner       = "terraform"
  github_repository = "eks-deployment-example"
  project           = "eks-deployment"
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      env               = local.env_name
      provisioner       = local.provisioner
      github-repository = local.github_repository
      project           = local.project
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
