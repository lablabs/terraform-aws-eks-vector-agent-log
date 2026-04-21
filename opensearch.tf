locals {
  opensearch_enabled       = var.enabled && var.opensearch_enabled
  opensearch_sinks_enabled = local.opensearch_enabled && (var.opensearch_sink_journald_enabled || var.opensearch_sink_kubernetes_logs_enabled)

  addon_values_opensearch = yamlencode({
    customConfig = {
      sinks = merge(
        var.opensearch_sink_kubernetes_logs_enabled ? {
          elasticsearch_kubernetes_containers = {
            type      = "elasticsearch"
            inputs    = ["kubernetes_containers"]
            endpoints = [var.opensearch_endpoint]
            mode      = "data_stream"
            bulk = {
              action = "create"
            }
            data_stream = {
              type      = "logs"
              dataset   = "kubernetes"
              namespace = "pods"
            }
            compression = "gzip"
            aws = {
              region = one(data.aws_region.current[*].name)
            }
          }
        } : {},
        var.opensearch_sink_journald_enabled ? {
          elasticsearch_journal = {
            type      = "elasticsearch"
            inputs    = ["journal"]
            endpoints = [var.opensearch_endpoint]
            mode      = "data_stream"
            bulk = {
              action = "create"
            }
            data_stream = {
              type      = "logs"
              dataset   = "journal"
              namespace = "hosts"
            }
            compression = "gzip"
            aws = {
              region = one(data.aws_region.current[*].name)
            }
          }
        } : {}
      )
    }
  })

  addon_values_opensearch_irsa = yamlencode({
    customConfig = {
      sinks = merge(
        var.opensearch_sink_kubernetes_logs_enabled ? {
          elasticsearch_kubernetes_containers = {
            auth = {
              assume_role = one(var.irsa_assume_role_arns)
            }
          }
        } : {},
        var.opensearch_sink_journald_enabled ? {
          elasticsearch_journal = {
            auth = {
              assume_role = one(var.irsa_assume_role_arns)
            }
          }
        } : {}
      )
    }
  })

  addon_values_opensearch_auth_strategy = yamlencode({
    customConfig = {
      sinks = merge(
        var.opensearch_sink_kubernetes_logs_enabled ? {
          elasticsearch_kubernetes_containers = {
            auth = {
              strategy = "aws"
            }
          }
        } : {},
        var.opensearch_sink_journald_enabled ? {
          elasticsearch_journal = {
            auth = {
              strategy = "aws"
            }
          }
        } : {}
      )
    }
  })
}
