data "aws_region" "current" {}

locals {
  cloudwatch_group_name_containers = try(aws_cloudwatch_log_group.cloudwatch_containers[0].name, "")
  cloudwatch_group_name_nodes      = try(aws_cloudwatch_log_group.cloudwatch_nodes[0].name, "")

  values_default = yamlencode({
    "image" : {
      "tag" : "0.31.0-debian"
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
          "endpoints" : [var.opensearch_endpoint],
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
          "aws" : {
            "region" : data.aws_region.current.name
          }
        },
        "elasticsearch_journal" : {
          "type" : "elasticsearch",
          "inputs" : ["journal"],
          "endpoints" : [var.opensearch_endpoint],
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

  helm_values_sink_loki_internal_logs = yamlencode({
    "customConfig" : {
      "transforms" : {
        "filter_logs" : {
          "type" : "filter",
          "inputs" : ["internal_logs"],
          "condition" : "(.metadata.level == \"WARN\") || (.metadata.level == \"ERROR\")"
        }
        "enrich_internal_logs" = {
          "type" = "remap"
          "inputs" = [
            "filter_logs"
          ]
          "source" = <<-EOT
            .kubernetes.pod_namespace = "$${VECTOR_SELF_POD_NAMESPACE:-null}"
            .kubernetes.pod_node_name = "$${VECTOR_SELF_NODE_NAME:-null}"
            .kubernetes.pod_name = "$${VECTOR_SELF_POD_NAME:-null}"
          EOT
        }
      },
      "sinks" : {
        "loki_internal_logs" : {
          "type" : "loki"
          "inputs" : ["enrich_internal_logs"]
          "endpoint" : var.loki_endpoint
          "out_of_order_action" : "accept"
          "remove_label_fields" : true
          "labels" : {
            "forwarder" : "vector"
            "cluster" : var.loki_label_cluster
            "log_source" : "internal_logs"
            "namespace" : "{{`{{ kubernetes.pod_namespace }}`}}"
            "node" : "{{`{{ kubernetes.pod_node_name }}`}}"
            "pod" : "{{`{{ kubernetes.pod_name }}`}}"
            "severity" : "{{`{{ .metadata.level }}`}}"
          }
          "encoding" : {
            "codec" : "json"
          }
        }
      }
      "sources" : {
        "internal_logs" : {
          "type" : "internal_logs"
        }
      }
    }
  })

  helm_values_sink_opensearch_auth_strategy = yamlencode({
    "customConfig" : {
      "sinks" : {
        "elasticsearch_kubernetes_containers" : {
          "auth" : {
            "strategy" : "aws",
          }
        },
        "elasticsearch_journal" : {
          "auth" : {
            "strategy" : "aws",
          }
        }
      }
    }
  })

  helm_values_sink_loki = yamlencode({
    "customConfig" : {
      "sinks" : {
        "loki_kubernetes_containers" : {
          "type" : "loki"
          "inputs" : ["kubernetes_containers"]
          "endpoint" : var.loki_endpoint
          "out_of_order_action" : "accept"
          "remove_label_fields" : true
          "labels" : {
            "app" : "{{`{{ kubernetes.pod_labels.\"app.kubernetes.io/name\" }}`}}"
            "container" : "{{`{{ kubernetes.container_name }}`}}"
            "forwarder" : "vector"
            "cluster" : var.loki_label_cluster
            "log_source" : "containers"
            "namespace" : "{{`{{ kubernetes.pod_namespace }}`}}"
            "node" : "{{`{{ kubernetes.pod_node_name }}`}}"
            "pod" : "{{`{{ kubernetes.pod_name }}`}}"
            "stream" : "{{`{{ .stream }}`}}"
          }
          "encoding" : {
            "codec" : "json"
          }
        }
        "loki_kubernetes_nodes" : {
          "type" : "loki"
          "inputs" : ["journal"]
          "endpoint" : var.loki_endpoint
          "out_of_order_action" : "accept"
          "remove_label_fields" : true
          "labels" : {
            "forwarder" : "vector"
            "cluster" : var.loki_label_cluster
            "log_source" : "nodes"
          }
          "encoding" : {
            "codec" : "json"
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
    var.opensearch_enabled && var.irsa_role_create ? local.helm_values_sink_opensearch_auth_strategy : "",
    var.opensearch_enabled && var.irsa_assume_role_enabled ? local.helm_values_sink_opensearch_assume_role : "",
    var.loki_enabled ? local.helm_values_sink_loki : "",
    var.loki_enabled && var.loki_internal_logs_enabled ? local.helm_values_sink_loki_internal_logs : "",
    var.values
  ])
}
