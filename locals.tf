locals {
  efs_security_group = {
    name        = "efs-security-group"
    description = "Security Group for the efs filesystem of the eks cluster."
    ingress = {
      http = {
        from     = 2049
        to       = 2049
        protocol = "tcp"
      }
    }
    egress = {
      http = {
        from     = 0
        to       = 0
        protocol = "-1"
      }
    }
  }
  
  vpc_id                      = data.aws_eks_cluster.eks_cluster.vpc_config[0].vpc_id
  subnet_ids                  = tolist(data.aws_eks_cluster.eks_cluster.vpc_config[0].subnet_ids)
  openid_connect_provider_url = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  openid_connect_provider_arn = data.aws_iam_openid_connect_provider.eks_cluster_oidc.arn
  eks_cluster_sg_id           = data.aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}