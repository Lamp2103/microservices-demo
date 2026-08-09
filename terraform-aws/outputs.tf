output "cluster_name" {
  description = "Tên cụm EKS Cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint để kết nối với EKS API Server"
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "ID của VPC"
  value       = module.vpc.vpc_id
}

output "ecr_repository_urls" {
  description = "Danh sách đường dẫn ECR Repositories"
  value       = { for k, v in aws_ecr_repository.microservices : k => v.repository_url }
}