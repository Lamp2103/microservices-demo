variable "aws_region" {
  description = "AWS region để dựng cluster"
  type        = string
  default     = "ap-southeast-1" # Singapore, gần VN nhất, độ trễ thấp
}

variable "project_name" {
  description = "Tên project, dùng làm tiền tố đặt tên tài nguyên"
  type        = string
  default     = "eks-observability-demo"
}

variable "environment" {
  description = "Môi trường (dev/staging/prod) - dùng để tag tài nguyên"
  type        = string
  default     = "dev"
}

variable "cluster_version" {
  description = <<-EOT
    Phiên bản Kubernetes cho EKS. QUAN TRỌNG: EKS chỉ tính $0.10/giờ cho control plane
    khi version còn "standard support" (~14 tháng từ lúc ra mắt trên EKS). Sau đó chuyển
    sang "extended support" và bị tính $0.60/giờ (gấp 6 lần) cho đến hết 26 tháng.
    Trước khi apply, kiểm tra version nào đang standard support bằng lệnh:
      aws eks describe-cluster-versions --output table
    rồi cập nhật giá trị default bên dưới cho phù hợp - KHÔNG dùng version đã cũ quá 14 tháng.
  EOT
  type        = string
  default     = "1.32" # kiểm tra lại bằng lệnh AWS CLI ở trên trước khi apply, vì lịch support thay đổi theo thời gian
}

variable "vpc_cidr" {
  description = "CIDR block cho VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Danh sách AZ sẽ dùng (tối thiểu 2 để EKS yêu cầu subnet ở nhiều AZ)"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "node_instance_type" {
  description = "Loại instance cho worker node. t3.medium đủ dùng cho demo (2 vCPU, 4GB RAM)"
  type        = string
  default     = "t3.medium"
}

variable "node_group_desired_size" {
  description = "Số node mong muốn trong node group"
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "Số node tối thiểu (dùng cho auto-scaling)"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Số node tối đa (dùng cho auto-scaling), để dư 1 node so với desired cho các bài test scale"
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Dung lượng ổ đĩa (GB) cho mỗi worker node"
  type        = number
  default     = 30
}

variable "enable_cluster_public_access" {
  description = "Cho phép truy cập EKS API endpoint từ internet (true tiện cho học tập/demo, nên tắt hoặc giới hạn IP trong môi trường thật)"
  type        = bool
  default     = true
}

variable "additional_iam_users" {
  description = "Danh sách ARN của IAM user khác cần quyền quản trị cluster (ngoài người chạy terraform apply), ví dụ cho giảng viên hướng dẫn xem cluster"
  type        = list(string)
  default     = []
}
