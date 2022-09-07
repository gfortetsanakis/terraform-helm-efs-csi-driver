# Terraform module for efs-csi-driver

This module deploys the following helm chart on an Amazon EKS cluster:

| Name               | Repository                                            | Version |
| ------------------ | ----------------------------------------------------- | ------- |
| aws-efs-csi-driver | https://kubernetes-sigs.github.io/aws-efs-csi-driver/ | 2.2.7   |

The module also deploys an EFS file system that will be used as storage backend for creating EFS volumes in the cluster along with a corresponding storage class.

## Module input parameters

| Parameter                    | Type     | Description                                                                                   |
| ---------------------------- | -------- | --------------------------------------------------------------------------------------------- |
| namespace                    | Required | The kubernetes namespace at which the efs-csi-driver chart will be deployed                   |
| eks_cluster_properties       | Required | A map variable containing properties of the EKS cluster                                       |
| subnet_ids                   | Required | The ids of the VPC subnets from which the EFS file system will be accessible                  |
| efs_csi_driver_controller_sa | Optional | The name of the service account to be created for efs csi driver controller                   |
| efs_csi_driver_node_sa       | Optional | The name of the service account to be created for efs csi driver node daemons                 |
| efs_storage_class            | Optional | The name of the storage class to be created. The default value is "efs-sc"                    |
| node_selector                | Optional | A map variable with nodeSelector labels applied when placing pods of the chart on the cluster |

The structure of the "eks_cluster_properties" variable is as follows:

```
eks_cluster_properties = {
  vpc_id                      = <ID of the VPC on which the EKS cluster is deployed>
  openid_connect_provider_url = <URL of OpenID connect provider of EKS cluster>
  openid_connect_provider_arn = <ARN of OpenID connect provider of EKS cluster>  
  subnet_ids                  = <A list with the IDs of the VPC subnets on which the EKS cluster is installed>
  eks_cluster_sg_id           = <ID of the security group created for the nodes of the EKS cluster>
}
```

## Module output parameters

| Parameter         | Description                                                 |
| ----------------- | ----------------------------------------------------------- |
| efs_storage_class | The name of the storage class created by the efs-csi-driver |