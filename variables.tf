# IMPORTANT: Add addon specific variables here
variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
  nullable    = false
}

variable "cloudwatch_enabled" {
  type        = bool
  default     = false
  description = "Variable indicating whether default cloudwatch group with iam role is created and configured as vector sink."
  nullable    = false
}

variable "cloudwatch_group_name_prefix" {
  type        = string
  default     = "/aws/eks"
  description = "The name of the log group."
  nullable    = false
}

variable "cloudwatch_group_containers_retention" {
  type        = number
  default     = 14
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  nullable    = false

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, 0], var.cloudwatch_group_containers_retention)
    error_message = "Cloudwatch group containers retention must be one of the following values: [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653] or zero (0) for no expiration."
  }
}

variable "cloudwatch_group_containers_kms_key_id" {
  type        = string
  default     = ""
  description = "The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested."
  nullable    = false
}

variable "cloudwatch_containers_tags" {
  type        = map(any)
  default     = {}
  description = "A map of tags to assign to the resource."
  nullable    = false
}

variable "cloudwatch_group_nodes_retention" {
  type        = number
  default     = 14
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  nullable    = false

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, 0], var.cloudwatch_group_nodes_retention)
    error_message = "Cloudwatch group nodes retention must be one of the following values: [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653] or zero (0) for no expiration."
  }
}

variable "cloudwatch_group_nodes_kms_key_id" {
  type        = string
  default     = ""
  description = "The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested."
  nullable    = false
}

variable "cloudwatch_nodes_tags" {
  type        = map(any)
  default     = {}
  description = "A map of tags to assign to the resource."
  nullable    = false
}

variable "opensearch_enabled" {
  type        = bool
  default     = false
  description = "Variable indicating whether default OpenSearch group with iam role is created and configured as Vector sink."
  nullable    = false
}

variable "opensearch_domain_arn" {
  type        = list(string)
  default     = ["*"]
  description = "List of OpenSearch arns to allow for the vector role. Default all OpenSearch domains."
  nullable    = false
}

variable "opensearch_endpoint" {
  type        = string
  default     = "https://opensearch.example.com"
  description = "Domain-specific endpoint used to submit index and data upload requests."
  nullable    = false
}

# Vector Loki sink configuration
variable "loki_enabled" {
  type        = bool
  default     = false
  description = "Variable indicating whether Loki is configured as Vector sink."
  nullable    = false
}

variable "loki_endpoint" {
  type        = string
  default     = "https://loki.example.com"
  description = "Domain-specific endpoint used to submit index and data upload requests."
  nullable    = false
}

variable "loki_label_cluster" {
  type        = string
  default     = "example-cluster"
  description = "Cluster label with kubernetes cluster name as a value. Labels are attached to each batch of events."
  nullable    = false
}

variable "loki_internal_logs_enabled" {
  type        = bool
  default     = false
  description = "Whether Vector internal logs should be sent to Loki."
  nullable    = false
}

variable "loki_internal_logs_severity" {
  type        = string
  default     = "warn"
  description = "The severity of internal logs to be sent to Loki."
  nullable    = false
}
