terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.43.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.aws_region

  default_tags {
    tags = {
      Billing  = "23G"
      Customer = "23G"
      Project  = "TerraformTesting"
    }
  }
}
