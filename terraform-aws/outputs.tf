output "cluster_name" {
  description = "Tên cluster EKS"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint API của EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "CA certificate data (cần cho kubeconfig)"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group ID của cluster"
  value       = module.eks.cluster_security_group_id
}

output "vpc_id" {
  description = "ID của VPC vừa tạo"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Danh sách private subnet ID (nơi worker node chạy)"
  value       = module.vpc.private_subnets
}

output "configure_kubectl" {
  description = "Lệnh để cấu hình kubectl trỏ vào cluster vừa tạo"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
