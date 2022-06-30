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
  default     = "vector"
  description = "Helm chart name to be installed"
}

variable "helm_chart_version" {
  type        = string
  default     = "0.13.0"
  description = "Version of the Helm chart"
}

variable "helm_release_name" {
  type        = string
  default     = "vector"
  description = "Helm release name"
}

variable "helm_repo_url" {
  type        = string
  default     = "https://helm.vector.dev"
  description = "Helm repository"
}

variable "helm_create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create k8s namespace with name defined by `namespace`"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "The K8s namespace in which the vector agent will be installed"
}

variable "rbac_create" {
  type        = bool
  default     = true
  description = "Whether to create and use RBAC resources"
}

variable "service_account_create" {
  type        = bool
  default     = true
  description = "Whether to create Service Account"
}

variable "service_account_name" {
  default     = "aws-vector-agent-log"
  description = "The k8s aws-vector-agent-log service account name"
}

variable "irsa_role_create" {
  type        = bool
  default     = true
  description = "Whether to create IRSA role and annotate service account"
}

variable "irsa_role_name_prefix" {
  type        = string
  default     = "vector-agent-log-irsa"
  description = "The IRSA role name prefix for vector"
}

variable "irsa_tags" {
  type        = map(string)
  default     = {}
  description = "IRSA resources tags"
}

variable "irsa_assume_role_enabled" {
  type        = bool
  default     = false
  description = "Whether IRSA is allowed to assume role defined by assume_role_arn."
}

variable "irsa_assume_role_arn" {
  default     = ""
  description = "Assume role arn. Assume role must be enabled."
}

variable "irsa_additional_policies" {
  type        = map(string)
  default     = {}
  description = "Map of the additional policies to be attached to default role. Where key is arbitrary id and value is policy arn."
}

variable "settings" {
  type        = map(any)
  default     = {}
  description = "Additional helm sets which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/vector/vector-agent"
}

variable "helm_set_sensitive" {
  type        = map(any)
  default     = {}
  description = "Value block with custom sensitive values to be merged with the values yaml that won't be exposed in the plan's diff"
}

variable "helm_postrender" {
  type        = map(any)
  default     = {}
  description = "Value block with a path to a binary file to run after helm renders the manifest which can alter the manifest contents"
}

variable "values" {
  type        = string
  default     = ""
  description = "Additional yaml encoded values which will be passed to the Helm chart"
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

# Vector OpenSearch sink configuration
variable "opensearch_enabled" {
  type        = bool
  default     = false
  description = "Variable indicating whether default opensearch group with iam role is created and configured as vector sink"
}

variable "opensearch_domain_arn" {
  type        = list(string)
  default     = ["*"]
  description = "List of OpenSearch arns to allow for the vector role. Default all OpenSearch domains."
}

variable "opensearch_domain_action" {
  type        = list(string)
  default     = ["es:ESHttpGet", "es:ESHttpPut", "es:ESHttpPost"]
  description = "List of actions to allow for the vector role, _e.g._ `es:ESHttpGet`, `es:ESHttpPut`, `es:ESHttpPost`"
}

variable "opensearch_endpoint" {
  type        = string
  default     = "https://opensearch.example.com"
  description = "Domain-specific endpoint used to submit index and data upload requests"
}

# Argo settings
variable "argo_namespace" {
  type        = string
  default     = "argo"
  description = "Namespace to deploy ArgoCD application CRD to"
}

variable "argo_enabled" {
  type        = bool
  default     = false
  description = "If set to true, the module will be deployed as ArgoCD application, otherwise it will be deployed as a Helm release"
}

variable "argo_helm_enabled" {
  type        = bool
  default     = false
  description = "If set to true, the ArgoCD Application manifest will be deployed using Kubernetes provider as a Helm release. Otherwise it'll be deployed as a Kubernetes manifest. See Readme for more info"
}

variable "argo_helm_values" {
  type        = string
  default     = ""
  description = "Value overrides to use when deploying argo application object with helm"
}

variable "argo_destination_server" {
  type        = string
  default     = "https://kubernetes.default.svc"
  description = "Destination server for ArgoCD Application"
}

variable "argo_project" {
  type        = string
  default     = "default"
  description = "ArgoCD Application project"
}

variable "argo_info" {
  default = [{
    "name"  = "terraform"
    "value" = "true"
  }]
  description = "ArgoCD info manifest parameter"
}

variable "argo_sync_policy" {
  description = "ArgoCD syncPolicy manifest parameter"
  default     = {}
}

variable "argo_metadata" {
  default = {
    "finalizers" : [
      "resources-finalizer.argocd.argoproj.io"
    ]
  }
  description = "ArgoCD Application metadata configuration. Override or create additional metadata parameters"
}

variable "argo_apiversion" {
  default     = "argoproj.io/v1alpha1"
  description = "ArgoCD Appliction apiVersion"
}

variable "argo_spec" {
  default     = {}
  description = "ArgoCD Application spec configuration. Override or create additional spec parameters"
}

variable "argo_kubernetes_manifest_computed_fields" {
  type        = list(string)
  default     = ["metadata.labels", "metadata.annotations"]
  description = "List of paths of fields to be handled as \"computed\". The user-configured value for the field will be overridden by any different value returned by the API after apply."
}

variable "argo_kubernetes_manifest_field_manager_name" {
  default     = "Terraform"
  description = "The name of the field manager to use when applying the kubernetes manifest resource. Defaults to Terraform"
}

variable "argo_kubernetes_manifest_field_manager_force_conflicts" {
  type        = bool
  default     = false
  description = "Forcibly override any field manager conflicts when applying the kubernetes manifest resource"
}

variable "argo_kubernetes_manifest_wait_fields" {
  type        = map(string)
  default     = {}
  description = "A map of fields and a corresponding regular expression with a pattern to wait for. The provider will wait until the field matches the regular expression. Use * for any value."
}

variable "helm_repo_key_file" {
  type        = string
  default     = ""
  description = "Helm repositories cert key file"
}

variable "helm_repo_cert_file" {
  type        = string
  default     = ""
  description = "Helm repositories cert file"
}

variable "helm_repo_ca_file" {
  type        = string
  default     = ""
  description = "Helm repositories cert file"
}

variable "helm_repo_username" {
  type        = string
  default     = ""
  description = "Username for HTTP basic authentication against the helm repository"
}

variable "helm_repo_password" {
  type        = string
  default     = ""
  description = "Password for HTTP basic authentication against the helm repository"
}

variable "helm_devel" {
  type        = bool
  default     = false
  description = "Use helm chart development versions, too. Equivalent to version '>0.0.0-0'. If version is set, this is ignored"
}

variable "helm_package_verify" {
  type        = bool
  default     = false
  description = "Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart"
}

variable "helm_keyring" {
  type        = string
  default     = "~/.gnupg/pubring.gpg"
  description = "Location of public keys used for verification. Used only if helm_package_verify is true"
}

variable "helm_timeout" {
  type        = number
  default     = 300
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks)"
}

variable "helm_disable_webhooks" {
  type        = bool
  default     = false
  description = "Prevent helm chart hooks from running"
}

variable "helm_reset_values" {
  type        = bool
  default     = false
  description = "When upgrading, reset the values to the ones built into the helm chart"
}

variable "helm_reuse_values" {
  type        = bool
  default     = false
  description = "When upgrading, reuse the last helm release's values and merge in any overrides. If 'helm_reset_values' is specified, this is ignored"
}

variable "helm_force_update" {
  type        = bool
  default     = false
  description = "Force helm resource update through delete/recreate if needed"
}

variable "helm_recreate_pods" {
  type        = bool
  default     = false
  description = "Perform pods restart during helm upgrade/rollback"
}

variable "helm_cleanup_on_fail" {
  type        = bool
  default     = false
  description = "Allow deletion of new resources created in this helm upgrade when upgrade fails"
}

variable "helm_release_max_history" {
  type        = number
  default     = 0
  description = "Maximum number of release versions stored per release"
}

variable "helm_atomic" {
  type        = bool
  default     = false
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used"
}

variable "helm_wait" {
  type        = bool
  default     = false
  description = "Will wait until all helm release resources are in a ready state before marking the release as successful. It will wait for as long as timeout"
}

variable "helm_wait_for_jobs" {
  type        = bool
  default     = false
  description = "If wait is enabled, will wait until all helm Jobs have been completed before marking the release as successful. It will wait for as long as timeout"
}

variable "helm_skip_crds" {
  type        = bool
  default     = false
  description = "If set, no CRDs will be installed before helm release"
}

variable "helm_render_subchart_notes" {
  type        = bool
  default     = true
  description = "If set, render helm subchart notes along with the parent"
}

variable "helm_disable_openapi_validation" {
  type        = bool
  default     = false
  description = "If set, the installation process will not validate rendered helm templates against the Kubernetes OpenAPI Schema"
}

variable "helm_dependency_update" {
  type        = bool
  default     = false
  description = "Runs helm dependency update before installing the chart"
}

variable "helm_replace" {
  type        = bool
  default     = false
  description = "Re-use the given name of helm release, only if that name is a deleted release which remains in the history. This is unsafe in production"
}

variable "helm_description" {
  type        = string
  default     = ""
  description = "Set helm release description attribute (visible in the history)"
}

variable "helm_lint" {
  type        = bool
  default     = false
  description = "Run the helm chart linter during the plan"
}
