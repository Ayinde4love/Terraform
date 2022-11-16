module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

cluster_name = "myapp-eks-cluster"
cluster_version = "1.22"
  vpc_id = module.myapp-vpc.vpc_id
  subnet_ids = module.myapp-vpc.private_subnets

  tags = {
  enviroment= "development"
  application= "myapp"
    }

  eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t2.small"]
    }
  }

}