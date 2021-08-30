variable "enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "cluster_identity_oidc_issuer" {
  type        = string
  description = "The OIDC Identity issuer for the cluster"
}

variable "cluster_identity_oidc_issuer_arn" {
  type        = string
  description = "The OIDC Identity issuer ARN for the cluster that can be used to associate IAM roles with a service account"
}

variable "helm_chart_name" {
  type        = string
  default     = "vector-agent"
  description = "Helm chart name to be installed"
}

variable "helm_chart_version" {
  type        = string
  default     = "0.15.1"
  description = "Version of the Helm chart"
}

variable "helm_release_name" {
  type        = string
  default     = "vector-agent"
  description = "Helm release name"
}

variable "helm_repo_url" {
  type        = string
  default     = "https://packages.timber.io/helm/latest"
  description = "Helm repository"
}

variable "helm_create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create k8s namespace with name defined by `k8s_namespace`"
}

variable "k8s_namespace" {
  type        = string
  default     = "kube-system"
  description = "The K8s namespace in which the external-dns will be installed"
}

variable "settings" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values to be merged with the values yaml, see https://artifacthub.io/packages/helm/vector/vector-agent"
}

variable "values" {
  type        = string
  default     = ""
  description = "Additional values. Values will be merged, in order, as Helm does with multiple -f options"
}

# Cloudwatch & Vector cloudwatch sink configuration
variable "cloudwatch_enabled" {
  type        = bool
  default     = false
  description = "Variable indicating whether default cloudwatch group with iam role is created and configured as vector sink"
}

variable "cloudwatch_group_name_prefix" {
  type        = string
  default     = "/aws/eks"
  description = "The name of the log group"
}

variable "cloudwatch_group_containers_retention" {
  type        = number
  default     = 14
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
}

variable "cloudwatch_group_containers_kms_key_id" {
  type        = string
  default     = ""
  description = "The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested."
}

variable "cloudwatch_containers_tags" {
  type        = map(any)
  default     = {}
  description = "A map of tags to assign to the resource."
}

variable "cloudwatch_group_nodes_retention" {
  type        = number
  default     = 14
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
}

variable "cloudwatch_group_nodes_kms_key_id" {
  type        = string
  default     = ""
  description = "The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested."
}

variable "cloudwatch_nodes_tags" {
  type        = map(any)
  default     = {}
  description = "A map of tags to assign to the resource."
}

variable "cloudwatch_role_name_prefix" {
  type        = string
  default     = "eks-irsa"
  description = "The role name prefix for vector cloudwatch ingest"
}
