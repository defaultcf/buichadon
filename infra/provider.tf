terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.37"
    }
  }

  backend "s3" {
    bucket = "tf-example-private"
    key    = "buichadon/terraform.tfstate"
    region = "us-east-1"
  }

  required_version = ">= 1.3.3"
}

provider "aws" {
  region = "us-east-1"
}
