locals {
  cloudwatch_enabled = var.enabled && var.cloudwatch_enabled

  addon_values_cloudwatch = yamlencode({
    customConfig = {
      sinks = {
        cloudwatch_kubernetes_containers = {
          type                 = "aws_cloudwatch_logs"
          inputs               = ["kubernetes_containers"]
          region               = one(data.aws_region.current[*].name)
          group_name           = one(aws_cloudwatch_log_group.cloudwatch_containers[*].name)
          stream_name          = "{{`{{ kubernetes.pod_namespace }}-{{ kubernetes.pod_name }}-{{ kubernetes.container_name }}`}}"
          create_missing_group = false
          encoding = {
            codec = "json"
          }
        }
        cloudwatch_journal = {
          type                 = "aws_cloudwatch_logs"
          inputs               = ["journal"]
          region               = one(data.aws_region.current[*].name)
          group_name           = one(aws_cloudwatch_log_group.cloudwatch_nodes[*].name)
          stream_name          = "{{`{{ host }}`}}"
          create_missing_group = false
          encoding = {
            codec = "json"
          }
        }
      }
    }
  })

  addon_values_cloudwatch_irsa = yamlencode({
    customConfig = {
      sinks = {
        aws_cloudwatch_logs = {
          auth = {
            assume_role = one(var.irsa_assume_role_arns)
          }
        }
      }
    }
  })
}

resource "aws_cloudwatch_log_group" "cloudwatch_containers" {
  #checkov:skip=CKV_AWS_338: By default, we want to retain cloudwatch logs for 14 days
  count = local.cloudwatch_enabled ? 1 : 0

  name              = "${var.cloudwatch_group_name_prefix}/containers"
  retention_in_days = var.cloudwatch_group_containers_retention
  kms_key_id        = var.cloudwatch_group_containers_kms_key_id

  tags = var.cloudwatch_containers_tags
}

resource "aws_cloudwatch_log_group" "cloudwatch_nodes" {
  #checkov:skip=CKV_AWS_338: By default, we want to retain cloudwatch logs for 14 days
  count = local.cloudwatch_enabled ? 1 : 0

  name              = "${var.cloudwatch_group_name_prefix}/nodes"
  retention_in_days = var.cloudwatch_group_nodes_retention
  kms_key_id        = var.cloudwatch_group_nodes_kms_key_id

  tags = var.cloudwatch_nodes_tags
}
