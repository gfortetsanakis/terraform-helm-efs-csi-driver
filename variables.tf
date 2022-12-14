variable "namespace" {
  description = "The kubernetes namespace at which the efs-csi-driver chart will be deployed."
}

variable "eks_cluster_properties" {
  description = "A map variable containing properties of the EKS cluster."
}

variable "efs_csi_driver_controller_sa" {
  description = "The name of the service account to be created for EFS csi driver controller."
  default     = "efs-csi-controller-sa"
}
variable "efs_csi_driver_node_sa" {
  description = "The name of the service account to be created for EFS csi driver node daemons."
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