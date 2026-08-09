locals {
  services = [
    "frontend",
    "cartservice",
    "checkoutservice",
    "productcatalogservice",
    "shippingservice",
    "paymentservice",
    "emailservice",
    "recommendationservice",
    "currencyservice",
    "adservice",
    "loadgenerator"
  ]
}

# Tạo ECR Repositories cho toàn bộ Microservices
resource "aws_ecr_repository" "microservices" {
  for_each             = toset(local.services)
  name                 = "online-boutique/${each.value}"
  image_tag_mutability = "MUTABLE"
  
  # Bổ sung dòng này để tự động xóa image khi hủy hạ tầng
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Tự động xóa bớt Docker Image cũ để tiết kiệm dung lượng lưu trữ trên AWS
resource "aws_ecr_lifecycle_policy" "cleanup_policy" {
  for_each   = aws_ecr_repository.microservices
  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Chỉ giữ lại 3 Docker Images gần nhất"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 3
      }
      action = {
        type = "expire"
      }
    }]
  })
}