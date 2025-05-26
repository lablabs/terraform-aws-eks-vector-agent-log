/**
 * # AWS Vector Log Agent Terraform module
 *
 * A Terraform module to deploy the [Vector](https://vector.dev/) agent on Amazon EKS cluster.
 *
 * [![Terraform validate](https://github.com/lablabs/terraform-aws-eks-vector-agent-log/actions/workflows/validate.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-vector-agent-log/actions/workflows/validate.yaml)
 * [![pre-commit](https://github.com/lablabs/terraform-aws-eks-vector-agent-log/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-vector-agent-log/actions/workflows/pre-commit.yml)
 */
locals {
  addon = {
    name      = "vector"
    namespace = "kube-system"

    helm_chart_name    = "vector"
    helm_chart_version = "0.40.0" # 0.44.0
    helm_repo_url      = "https://helm.vector.dev"
  }

  addon_irsa = {
    (local.addon.name) = {
      irsa_policy_enabled = local.irsa_policy_enabled
      irsa_policy = var.irsa_policy != null ? var.irsa_policy : one(
        compact([ # either CloudWatch or OpenSearch policy can be used
          one(data.aws_iam_policy_document.cloudwatch[*].json),
          one(data.aws_iam_policy_document.opensearch[*].json),
        ])
      )
    }
  }

  addon_values_default = yamlencode({
    image = {
      tag = "0.31.0-debian"
    }
    role = "Agent"
    service = {
      enabled = false
    }
    tolerations = [{
      operator = "Exists"
      effect   = "NoSchedule"
    }]
    rbac = {
      create = module.addon-irsa[local.addon.name].rbac_create
    }
    serviceAccount = {
      create = module.addon-irsa[local.addon.name].service_account_create
      name   = module.addon-irsa[local.addon.name].service_account_name
      annotations = module.addon-irsa[local.addon.name].irsa_role_enabled ? {
        "eks.amazonaws.com/role-arn" = module.addon-irsa[local.addon.name].iam_role_attributes.arn
      } : tomap({})
    }
    extraVolumes = [{
      name = "etc"
      hostPath = {
        path = "/etc"
      }
    }]
    extraVolumeMounts = [{
      name      = "etc"
      mountPath = "/etc/machine-id"
      subPath   = "machine-id"
      readOnly  = true
    }]
    customConfig = {
      data_dir = "/vector-data-dir"
      api = {
        enabled = false
      }
      sources = {
        journal = {
          type = "journald"
        }
        kubernetes_containers = {
          type = "kubernetes_logs"
        }
      }
    }
  })

  addon_values = one(data.utils_deep_merge_yaml.addon_values[*].output)
}

data "aws_region" "current" {
  count = var.enabled ? 1 : 0
}

data "utils_deep_merge_yaml" "addon_values" {
  count = var.enabled ? 1 : 0

  input = compact([
    local.addon_values_default,

    var.cloudwatch_enabled ? local.addon_values_cloudwatch : "",
    var.cloudwatch_enabled && local.irsa_assume_role_enabled ? local.addon_values_cloudwatch_irsa : "",

    var.opensearch_enabled ? local.addon_values_opensearch : "",
    var.opensearch_enabled && module.addon-irsa[local.addon.name].irsa_role_enabled ? local.addon_values_opensearch_auth_strategy : "",
    var.opensearch_enabled && local.irsa_assume_role_enabled ? local.addon_values_opensearch_irsa : "",

    var.loki_enabled ? local.addon_values_loki : "",
    var.loki_enabled && var.loki_internal_logs_enabled ? local.addon_values_loki_internal_logs : "",
  ])
}
