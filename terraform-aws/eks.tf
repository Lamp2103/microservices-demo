module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = "observability-demo-cluster"
  cluster_version = "1.31" # Đặt cố định 1.30 (KHÔNG hạ xuống 1.29)

  cluster_endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    demo_nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      
      # Khai báo AMI AL2023 bắt buộc cho K8s 1.30
      ami_type       = "AL2023_x86_64_STANDARD"
    }
  }

  enable_cluster_creator_admin_permissions = true
}