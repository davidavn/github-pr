terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17"
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
