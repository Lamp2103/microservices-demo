# Dùng module chính thức từ terraform-aws-modules để đảm bảo cấu hình chuẩn,
# đã được cộng đồng kiểm chứng rộng rãi cho việc dựng VPC phục vụ EKS.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs = var.availability_zones

  # Chia CIDR: private subnet cho worker node, public subnet cho load balancer/NAT
  private_subnets = [for i, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, i)]
  public_subnets  = [for i, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, i + 100)]

  enable_nat_gateway   = true
  single_nat_gateway   = true # 1 NAT Gateway chung để tiết kiệm chi phí (đủ cho demo, không cần HA)
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Các tag bắt buộc để EKS + AWS Load Balancer Controller nhận diện đúng subnet
  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}
