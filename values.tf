data "aws_region" "current" {}

locals {
  cloudwatch_group_name_containers = try(aws_cloudwatch_log_group.cloudwatch_containers[0].name, "")
  cloudwatch_group_name_nodes      = try(aws_cloudwatch_log_group.cloudwatch_nodes[0].name, "")

  values_default = yamlencode({
    "image" : {
      "tag" : "0.22.2-debian"
    }
    "role" : "Agent"
    "service" : {
      "enabled" : false
    }
    "tolerations" : [{
      "operator" : "Exists",
      "effect" : "NoSchedule"
    }],
    "rbac" : {
      "create" : var.rbac_create
    },
    "serviceAccount" : {
      "create" : var.service_account_create
      "name" : var.service_account_name
      "annotations" : {
        "eks.amazonaws.com/role-arn" : local.irsa_role_create ? aws_iam_role.this[0].arn : ""
      }
    },
    "extraVolumes" : [{
      "name" : "etc",
      "hostPath" : {
        "path" : "/etc"
      }
    }],
    "extraVolumeMounts" : [{
      "name" : "etc",
      "mountPath" : "/etc/machine-id",
      "subPath" : "machine-id",
      "readOnly" : true
    }],
    "customConfig" : {
      "data_dir" : "/vector-data-dir"
      "api" : {
        "enabled" : false
      }
      "sources" : {
        "journal" : {
          "type" : "journald"
        }
        "kubernetes_containers" : {
          "type" : "kubernetes_logs"
        }
      }
    }
  })

  helm_values_sink_cloudwatch = yamlencode({
    "customConfig" : {
      "sinks" : {
        "cloudwatch_kubernetes_containers" : {
          "type" : "aws_cloudwatch_logs",
          "inputs" : ["kubernetes_containers"],
          "region" : data.aws_region.current.name,
          "group_name" : local.cloudwatch_group_name_containers,
          "stream_name" : "{{`{{ kubernetes.pod_namespace }}-{{ kubernetes.pod_name }}-{{ kubernetes.container_name }}`}}",
          "create_missing_group" : false,
          "encoding" : {
            "codec" : "json"
          }
        },
        "cloudwatch_journal" : {
          "type" : "aws_cloudwatch_logs",
          "inputs" : ["journal"],
          "region" : data.aws_region.current.name,
          "group_name" : local.cloudwatch_group_name_nodes,
          "stream_name" : "{{`{{ host }}`}}",
          "create_missing_group" : false,
          "encoding" : {
            "codec" : "json"
          }
        }
      }
    }
  })

  helm_values_sink_cloudwatch_assume_role = yamlencode({
    "customConfig" : {
      "sinks" : {
        "elasticsearch_kubernetes_containers" : {
          "auth" : {
            "assume_role" : var.irsa_assume_role_arn
          }
        },
        "elasticsearch_journal" : {
          "auth" : {
            "assume_role" : var.irsa_assume_role_arn
          }
        }
      }
    }
  })

  helm_values_sink_opensearch = yamlencode({
    "customConfig" : {
      "sinks" : {
        "elasticsearch_kubernetes_containers" : {
          "type" : "elasticsearch",
          "inputs" : ["kubernetes_containers"],
          "endpoint" : var.opensearch_endpoint,
          "mode" : "data_stream",
          "bulk" : {
            "action" : "create"
          },
          "data_stream" : {
            "type" : "logs",
            "dataset" : "kubernetes",
            "namespace" : "pods"
          },
          "compression" : "gzip",
          "auth" : {
            "strategy" : "aws",
          },
          "aws" : {
            "region" : data.aws_region.current.name
          }
        },
        "elasticsearch_journal" : {
          "type" : "elasticsearch",
          "inputs" : ["journal"],
          "endpoint" : var.opensearch_endpoint,
          "mode" : "data_stream",
          "bulk" : {
            "action" : "create"
          },
          "data_stream" : {
            "type" : "logs",
            "dataset" : "journal",
            "namespace" : "hosts"
          },
          "compression" : "gzip",
          "auth" : {
            "strategy" : "aws",
          },
          "aws" : {
            "region" : data.aws_region.current.name
          }
        }
      }
    }
  })

  helm_values_sink_opensearch_assume_role = yamlencode({
    "customConfig" : {
      "sinks" : {
        "elasticsearch_kubernetes_containers" : {
          "auth" : {
            "assume_role" : var.irsa_assume_role_arn
          }
        },
        "elasticsearch_journal" : {
          "auth" : {
            "assume_role" : var.irsa_assume_role_arn
          }
        }
      }
    }
  })
}

data "utils_deep_merge_yaml" "values" {
  count = var.enabled ? 1 : 0
  input = compact([
    local.values_default,
    var.cloudwatch_enabled ? local.helm_values_sink_cloudwatch : "",
    var.cloudwatch_enabled && var.irsa_assume_role_enabled ? local.helm_values_sink_cloudwatch_assume_role : "",
    var.opensearch_enabled ? local.helm_values_sink_opensearch : "",
    var.opensearch_enabled && var.irsa_assume_role_enabled ? local.helm_values_sink_opensearch_assume_role : "",
    var.values
  ])
}
