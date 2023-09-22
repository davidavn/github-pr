terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.37"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
  backend "s3" {
    bucket         = "terraform-state-gh-webhook"
    key            = "state"
    region         = "ca-central-1"
    dynamodb_table = "app-state-gh-webhook"
  }
}

provider "aws" {
  region  = "ca-central-1"
  profile = "terraform"
}

provider "github" {
  token = var.github_token
}
