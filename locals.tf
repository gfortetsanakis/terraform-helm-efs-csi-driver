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

  openid_connect_provider_url = replace(var.eks_cluster_properties["openid_connect_provider_url"], "https://", "")
  openid_connect_provider_arn = var.eks_cluster_properties["openid_connect_provider_arn"]
  vpc_id                      = var.eks_cluster_properties["vpc_id"]
  eks_cluster_sg_id           = var.eks_cluster_properties["eks_cluster_sg_id"]
  subnet_ids                  = var.eks_cluster_properties["subnet_ids"]
}