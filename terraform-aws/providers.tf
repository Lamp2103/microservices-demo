terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Khuyến nghị: dùng remote backend (S3 + DynamoDB lock) thay vì local state
  # khi làm việc nhóm hoặc muốn destroy/apply an toàn từ nhiều máy.
  # Bỏ comment và điền tên bucket/table của bạn nếu muốn dùng:
  #
  # backend "s3" {
  #   bucket         = "ten-bucket-luu-state-cua-ban"
  #   key            = "eks-observability/terraform.tfstate"
  #   region         = "ap-southeast-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
