data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_iam_openid_connect_provider" "eks_cluster_oidc" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_efs_file_system" "efs_storage_for_eks" {
  creation_token   = "efs_storage_for_eks"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"

  tags = {
    Name = "efs-storage-for-eks"
  }
}

resource "aws_iam_policy" "efs_access_policy" {
  name        = "efs_access_policy"
  description = "Policy used to access efs from eks"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets",
          "ec2:DescribeAvailabilityZones"
        ],
        "Resource" : "${aws_efs_file_system.efs_storage_for_eks.arn}"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:CreateAccessPoint"
        ],
        "Resource" : "${aws_efs_file_system.efs_storage_for_eks.arn}",
        "Condition" : {
          "StringLike" : {
            "aws:RequestTag/efs.csi.aws.com/cluster" : "true"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : "elasticfilesystem:DeleteAccessPoint",
        "Resource" : "${aws_efs_file_system.efs_storage_for_eks.arn}",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/efs.csi.aws.com/cluster" : "true"
          }
        }
      }
    ]
  })
}

resource "aws_security_group" "efs_sg" {
  name        = local.efs_security_group["name"]
  description = local.efs_security_group["description"]
  vpc_id      = local.vpc_id

  dynamic "ingress" {
    for_each = local.efs_security_group["ingress"]
    content {
      from_port       = ingress.value.from
      to_port         = ingress.value.to
      protocol        = ingress.value.protocol
      security_groups = [local.eks_cluster_sg_id]
    }
  }

  dynamic "egress" {
    for_each = local.efs_security_group["egress"]
    content {
      from_port       = egress.value.from
      to_port         = egress.value.to
      protocol        = egress.value.protocol
      security_groups = [local.eks_cluster_sg_id]
    }
  }
}

resource "aws_efs_mount_target" "efs-mt" {
  count           = length(local.subnet_ids)
  file_system_id  = aws_efs_file_system.efs_storage_for_eks.id
  subnet_id       = local.subnet_ids[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_iam_role" "efs" {
  for_each = {
    "csi_driver_controller_role" : "${var.efs_csi_driver_controller_sa}"
    "csi_driver_node_role" : "${var.efs_csi_driver_node_sa}"
  }
  name = each.key
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${local.openid_connect_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.openid_connect_provider_url}:sub" : "system:serviceaccount:${var.namespace}:${each.value}"
          }
        }
      }
    ]
  })

  tags = {
    "ServiceAccountName"      = each.value
    "ServiceAccountNameSpace" = var.namespace
  }

  managed_policy_arns = [aws_iam_policy.efs_access_policy.arn]
}

resource "helm_release" "aws_efs_csi_driver" {
  chart           = "aws-efs-csi-driver"
  name            = "aws-efs-csi-driver"
  namespace       = var.namespace
  create_namespace = true
  repository      = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  version         = "2.2.7"
  wait            = true

  values = [
    templatefile("${path.module}/templates/aws-efs-csi-driver.yaml", {
      node_selector                      = var.node_selector
      efs_id                             = aws_efs_file_system.efs_storage_for_eks.id
      efs_csi_driver_controller_sa       = var.efs_csi_driver_controller_sa
      efs_csi_driver_controller_role_arn = aws_iam_role.efs["csi_driver_controller_role"].arn
      efs_csi_driver_node_sa             = var.efs_csi_driver_node_sa
      efs_csi_driver_node_role_arn       = aws_iam_role.efs["csi_driver_node_role"].arn
      efs_storage_class                  = var.efs_storage_class
    })
  ]
}