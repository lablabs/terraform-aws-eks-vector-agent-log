module "vector_log_cloudwatch_helm" {
  source = "../../"

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  cluster_identity_oidc_issuer           = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn       = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
  cloudwatch_group_nodes_kms_key_id      = "1234abcd-12ab-34cd-56ef-1234567890ab"
  cloudwatch_group_containers_kms_key_id = "1234abcd-12ab-34cd-56ef-1234567890ab"
  namespace                              = "logging"

  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }

  cloudwatch_enabled = true

}

module "vector_log_cloudwatch_argo_manifests" {
  source = "../../"

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = false

  cluster_identity_oidc_issuer           = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn       = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
  cloudwatch_group_nodes_kms_key_id      = "1234abcd-12ab-34cd-56ef-1234567890ab"
  cloudwatch_group_containers_kms_key_id = "1234abcd-12ab-34cd-56ef-1234567890ab"
  namespace                              = "logging"

  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }

  cloudwatch_enabled = true

}

module "vector_log_cloudwatch_argo_helm" {
  source = "../../"

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = true

  cluster_identity_oidc_issuer           = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn       = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
  cloudwatch_group_nodes_kms_key_id      = "1234abcd-12ab-34cd-56ef-1234567890ab"
  cloudwatch_group_containers_kms_key_id = "1234abcd-12ab-34cd-56ef-1234567890ab"
  namespace                              = "logging"

  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }

  cloudwatch_enabled = true

}

module "vector_log_opensearch" {
  source = "../../"

  #-------------------------------------------
  # Argo instal using Helm chart:
  #   argo_enabled      = true
  #   argo_helm_enabled = true
  #-------------------------------------------
  # Argo instal using K8S manifests:
  #   argo_enabled      = true
  #   argo_helm_enabled = false
  #-------------------------------------------
  # Helm Install without Argo:
  #   argo_enabled      = false
  #   argo_helm_enabled = false
  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = true

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
  namespace                        = "logging"

  opensearch_domain_arn = ["arn:aws:es:eu-central-1:123456789012:domain/opensearch-cluster-arn"]

  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }

  opensearch_enabled  = true
  opensearch_endpoint = "https://opensearch.organization.com"

}

module "vector_log_loki" {
  source = "../../"

  #-------------------------------------------
  # Argo instal using Helm chart:
  #   argo_enabled      = true
  #   argo_helm_enabled = true
  #-------------------------------------------
  # Argo instal using K8S manifests:
  #   argo_enabled      = true
  #   argo_helm_enabled = false
  #-------------------------------------------
  # Helm Install without Argo:
  #   argo_enabled      = false
  #   argo_helm_enabled = false
  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = true

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn

  namespace = "logging"

  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }

  loki_enabled       = true
  loki_endpoint      = "https://gateway.liki.organization.com"
  loki_label_cluster = "organization-prod-cluster"

}
