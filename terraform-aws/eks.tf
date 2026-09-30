module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = "observability-demo-cluster"
  cluster_version = "1.34"

  cluster_endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

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

    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    demo_nodes = {
      min_size     = 2
      max_size     = 4
      desired_size = 3

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"

      ami_type = "AL2023_x86_64_STANDARD"
    }
  }
}