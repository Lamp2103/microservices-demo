locals {
  # Danh sách 11 microservice cần build image riêng (redis-cart dùng public image
  # có sẵn từ Docker Hub nên không cần ECR repo).
  microservices = [
    "frontend",
    "cartservice",
    "checkoutservice",
    "currencyservice",
    "emailservice",
    "paymentservice",
    "productcatalogservice",
    "recommendationservice",
    "shippingservice",
    "adservice",
    "loadgenerator",
  ]
}

resource "aws_ecr_repository" "microservices" {
  for_each = toset(local.microservices)

  name                 = "${var.project_name}/${each.value}"
  image_tag_mutability = "IMMUTABLE" # ngăn ghi đè tag đã tồn tại (VD: không cho push lại tag "v1" khác nội dung)

  image_scanning_configuration {
    scan_on_push = true # tự động quét lỗ hổng bảo mật mỗi lần push image
  }

  force_delete = true # cho phép terraform destroy xóa repo kể cả khi còn image bên trong (tiện cho demo)
}

# Lifecycle policy: chỉ giữ lại 10 image gần nhất mỗi repo để tránh phát sinh
# chi phí lưu trữ khi build/push nhiều lần trong quá trình phát triển CI/CD.
resource "aws_ecr_lifecycle_policy" "microservices" {
  for_each = aws_ecr_repository.microservices

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Chỉ giữ 10 image gần nhất"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "ecr_repository_urls" {
  description = "URL của từng ECR repository, dùng để docker tag/push và trong manifest deployment"
  value       = { for name, repo in aws_ecr_repository.microservices : name => repo.repository_url }
}
