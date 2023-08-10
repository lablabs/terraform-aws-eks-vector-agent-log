module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"

  name               = "vector-agent-log-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["eu-central-1a", "eu-central-1b"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
}

module "eks_cluster" {
  source  = "cloudposse/eks-cluster/aws"
  version = "0.43.2"

  region     = "eu-central-1"
  subnet_ids = module.vpc.public_subnets
  vpc_id     = module.vpc.vpc_id
  name       = "vector-agent-log"
}

module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "0.25.0"

  cluster_name   = "vector-agent-log"
  instance_types = ["t3.medium"]
  subnet_ids     = module.vpc.public_subnets
  min_size       = 1
  desired_size   = 1
  max_size       = 2
  depends_on     = [module.eks_cluster.kubernetes_config_map_id]
}

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
