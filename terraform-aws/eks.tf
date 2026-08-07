locals {
  cluster_name = "${var.project_name}-${var.environment}"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = var.enable_cluster_public_access

  # Tự động cấp quyền admin cluster cho IAM user/role đang chạy terraform apply,
  # cộng thêm danh sách additional_iam_users nếu có (VD: giảng viên hướng dẫn)
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    for idx, arn in var.additional_iam_users : "extra-admin-${idx}" => {
      principal_arn = arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_groups = {
    default = {
      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      instance_types = [var.node_instance_type]
      capacity_type  = "ON_DEMAND" # đổi thành "SPOT" nếu muốn tiết kiệm chi phí hơn nữa cho demo

      disk_size = var.node_disk_size

      labels = {
        role = "general"
      }

      tags = {
        "Name" = "${local.cluster_name}-node"
      }
    }
  }

  # Cho phép các add-on EKS quan trọng được quản lý qua module luôn,
  # thay vì cài thủ công sau khi cluster đã lên
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
}
