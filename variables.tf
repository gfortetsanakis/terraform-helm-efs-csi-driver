variable "namespace" {
  description = "The kubernetes namespace at which the efs-csi-driver chart will be deployed."
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster at which the efs csi driver will be installed."
}

variable "subnet_ids" {
  description = "The ids of the VPC subnets that will be able to access the EFS file system."
}

variable "efs_csi_driver_controller_sa" {
  description = "The name of the service account to be created for efs csi driver controller."
  default     = "efs-csi-controller-sa"
}
variable "efs_csi_driver_node_sa" {
  description = "The name of the service account to be created for efs csi driver node daemons."
  default     = "efs-csi-node-sa"
}

variable "efs_storage_class" {
  description = "The name of the storage class to be created in kubernetes."
  default     = "efs-sc"
}

variable "node_selector" {
  description = "A map variable with nodeSelector labels applied when placing pods of the chart on the cluster."
  default     = {}
}