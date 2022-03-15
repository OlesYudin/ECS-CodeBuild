terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.70.0"
    }
  }
}

provider "aws" {
  region = var.region # instant region
  # profile = var.profile # default user
}
