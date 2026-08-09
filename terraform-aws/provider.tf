terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1" # Region Singapore để tối ưu độ trễ về Việt Nam

  default_tags {
    tags = {
      Project     = "Observability-SRE-Internship"
      Environment = "Demo"
    }
  }
}