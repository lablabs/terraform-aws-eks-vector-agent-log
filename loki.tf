locals {
  addon_values_loki_internal_logs = yamlencode({
    customConfig = {
      transforms = {
        loki_internal_logs_severity_filter = {
          type      = "filter"
          inputs    = ["loki_internal_logs_severity_map"]
          condition = "includes(array(.log_levels.${upper(var.loki_internal_logs_severity)}) ?? [], .metadata.level)"
        }
        loki_internal_logs_severity_map = {
          type = "remap"
          inputs = [
            "internal_logs"
          ]
          source = <<-EOT
            .log_levels.TRACE  = ["TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"]
            .log_levels.DEBUG  = ["DEBUG", "INFO", "WARN", "ERROR", "FATAL"]
            .log_levels.INFO   = ["INFO", "WARN", "ERROR", "FATAL"]
            .log_levels.WARN   = ["WARN", "ERROR", "FATAL"]
            .log_levels.ERROR  = ["ERROR", "FATAL"]
            .log_levels.FATAL  = ["FATAL"]
          EOT
        }
        loki_internal_logs_enrichment = {
          type = "remap"
          inputs = [
            "loki_internal_logs_severity_filter"
          ]
          source = <<-EOT
            .kubernetes.pod_namespace = "$${VECTOR_SELF_POD_NAMESPACE:-null}"
            .kubernetes.pod_node_name = "$${VECTOR_SELF_NODE_NAME:-null}"
            .kubernetes.pod_name = "$${VECTOR_SELF_POD_NAME:-null}"
            del(.log_levels)
          EOT
        }
      }
      sinks = {
        loki_internal_logs = {
          type                = "loki"
          inputs              = ["loki_internal_logs_enrichment"]
          endpoint            = var.loki_endpoint
          out_of_order_action = "accept"
          remove_label_fields = true
          labels = {
            forwarder  = "vector"
            cluster    = var.loki_label_cluster
            log_source = "internal_logs"
            namespace  = "{{`{{ kubernetes.pod_namespace }}`}}"
            node       = "{{`{{ kubernetes.pod_node_name }}`}}"
            pod        = "{{`{{ kubernetes.pod_name }}`}}"
            severity   = "{{`{{ .metadata.level }}`}}"
          }
          encoding = {
            codec = "json"
          }
        }
      }
      sources = {
        internal_logs = {
          type = "internal_logs"
        }
      }
    }
  })

  addon_values_loki = yamlencode({
    customConfig = {
      sinks = {
        loki_kubernetes_containers = {
          type                = "loki"
          inputs              = ["kubernetes_containers"]
          endpoint            = var.loki_endpoint
          out_of_order_action = "accept"
          remove_label_fields = true
          labels = {
            app        = "{{`{{ kubernetes.pod_labels.\"app.kubernetes.io/name\" }}`}}"
            container  = "{{`{{ kubernetes.container_name }}`}}"
            forwarder  = "vector"
            cluster    = var.loki_label_cluster
            log_source = "containers"
            namespace  = "{{`{{ kubernetes.pod_namespace }}`}}"
            node       = "{{`{{ kubernetes.pod_node_name }}`}}"
            pod        = "{{`{{ kubernetes.pod_name }}`}}"
            stream     = "{{`{{ .stream }}`}}"
          }
          encoding = {
            codec = "json"
          }
        }
        loki_kubernetes_nodes = {
          type                = "loki"
          inputs              = ["journal"]
          endpoint            = var.loki_endpoint
          out_of_order_action = "accept"
          remove_label_fields = true
          labels = {
            forwarder  = "vector"
            cluster    = var.loki_label_cluster
            log_source = "nodes"
          }
          encoding = {
            codec = "json"
          }
        }
      }
    }
  })
}
