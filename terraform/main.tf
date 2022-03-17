terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }
  backend "s3" {
    bucket = "demo-tfstate-s3-dev"
    key    = "tfstate/terraform.tfstate"
    region = "us-east-2"
    # dynamodb_table = "demo-dynamodb-lock-dev"
    encrypt = true
  }
}

provider "aws" {
  region = var.region # instant region
  # profile = var.profile # default user
}
