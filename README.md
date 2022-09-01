# Terraform module for efs-csi-driver

This module deploys an efs-csi-driver service on an Amazon EKS cluster. Specifically, it deployes a new EFS file system that will be used as storage backend for creating volumes in the cluster. For this purpose the module creates a new storageclass for EFS storage.

## Module input parameters

| Parameter                    | Type     | Description                                                                         |
| ---------------------------- |--------- | ----------------------------------------------------------------------------------- |
| namespace                    | Required | The kubernetes namespace at which the efs-csi-driver chart will be deployed         |
| eks_cluster_name             | Required | The name of the eks cluster at which the efs csi driver will be installed           |
| efs_csi_driver_controller_sa | Optional | The name of the service account to be created for efs csi driver controller         |
| efs_csi_driver_node_sa       | Optional | The name of the service account to be created for efs csi driver node daemons       |
| efs_storage_class            | Optional | The name of the storage class to be created. The default value is \"efs-sc\"        |
| node_selector                | Optional | A map variable with nodeSelector labels applied when placing pods of the chart on the cluster |

## Module output parameters

| Parameter         | Description                                             |
| ----------------- | ------------------------------------------------------- |
| efs_storage_class | The name of the storage class created by efs-csi-driver |