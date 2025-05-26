module "addon_installation_disabled" {
  source = "../../"

  enabled = false

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
}

module "addon_installation_helm" {
  source = "../../"

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn

  # Either CloudWatch, OpenSearch or Loki must be enabled
  cloudwatch_enabled                     = false # set to true to enable CloudWatch logging
  cloudwatch_group_containers_kms_key_id = "1234abcd-12ab-34cd-56ef-1234567890ab"
  cloudwatch_group_nodes_kms_key_id      = "1234abcd-12ab-34cd-56ef-1234567890ab"

  opensearch_enabled    = false # set to true to enable OpenSearch logging
  opensearch_domain_arn = ["*"]
  opensearch_endpoint   = "https://opensearch.example.com"

  loki_enabled       = false # set to true to enable Loki logging
  loki_endpoint      = "https://loki.example.com"
  loki_label_cluster = module.eks_cluster.eks_cluster_id

  values = yamlencode({
    # insert sample values here
  })
}

# Please, see README.md and Argo Kubernetes deployment method for implications of using Kubernetes installation method
module "addon_installation_argo_kubernetes" {
  source = "../../"

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = false

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn

  # Either CloudWatch, OpenSearch or Loki must be enabled
  cloudwatch_enabled                     = false # set to true to enable CloudWatch logging
  cloudwatch_group_containers_kms_key_id = "1234abcd-12ab-34cd-56ef-1234567890ab"
  cloudwatch_group_nodes_kms_key_id      = "1234abcd-12ab-34cd-56ef-1234567890ab"

  opensearch_enabled    = false # set to true to enable OpenSearch logging
  opensearch_domain_arn = ["*"]
  opensearch_endpoint   = "https://opensearch.example.com"

  loki_enabled  = false # set to true to enable Loki logging
  loki_endpoint = "https://loki.example.com"

  values = yamlencode({
    # insert sample values here
  })

  argo_sync_policy = {
    automated   = {}
    syncOptions = ["CreateNamespace=true"]
  }
}

module "addon_installation_argo_helm" {
  source = "../../"

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = true

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn

  # Either CloudWatch, OpenSearch or Loki must be enabled
  cloudwatch_enabled                     = false # set to true to enable CloudWatch logging
  cloudwatch_group_containers_kms_key_id = "1234abcd-12ab-34cd-56ef-1234567890ab"
  cloudwatch_group_nodes_kms_key_id      = "1234abcd-12ab-34cd-56ef-1234567890ab"

  opensearch_enabled    = false # set to true to enable OpenSearch logging
  opensearch_domain_arn = ["*"]
  opensearch_endpoint   = "https://opensearch.example.com"

  loki_enabled  = false # set to true to enable Loki logging
  loki_endpoint = "https://loki.example.com"

  values = yamlencode({
    # insert sample values here
  })

  argo_sync_policy = {
    automated   = {}
    syncOptions = ["CreateNamespace=true"]
  }
}
