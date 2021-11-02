locals {
  k8s_irsa_role_create             = var.enabled && var.k8s_rbac_create && var.k8s_service_account_create && var.k8s_irsa_role_create
  k8s_service_account_name         = "${var.helm_chart_name}-${var.helm_release_name}"
  cloudwatch_group_name_containers = try(aws_cloudwatch_log_group.cloudwatch_containers[0].name, "")
  cloudwatch_group_name_nodes      = try(aws_cloudwatch_log_group.cloudwatch_nodes[0].name, "")

  values_default = yamlencode({
    "podValuesChecksumAnnotation" : "true",
    "tolerations" : [{
      "operator" : "Exists",
      "effect" : "NoSchedule"
    }],
    "rbac" : {
      "enabled" : var.k8s_rbac_create
    },
    "serviceAccount" : {
      "create" : var.k8s_service_account_create
      "name" : local.k8s_service_account_name
      "annotations" : {
        "eks.amazonaws.com/role-arn" : local.k8s_irsa_role_create ? aws_iam_role.vector[0].arn : ""
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
      "sources" : {
        "kubelet" : {
          "type" : "journald",
          "include_units" : ["kubelet"]
        },
        "containerd" : {
          "type" : "journald",
          "include_units" : ["containerd"]
        },
        "docker" : {
          "type" : "journald",
          "include_units" : ["docker"]
        },
        "kubernetes_logs" : {
          "type" : "kubernetes_logs"
        }
      }
    }
  })

  values_sink_cloudwatch = yamlencode({
    "customConfig" : {
      "sinks" : {
        "cloudwatch_containers" : {
          "type" : "aws_cloudwatch_logs",
          "inputs" : ["kubernetes_logs"],
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
          "inputs" : ["kubelet", "containerd", "docker"],
          "region" : data.aws_region.current.name,
          "group_name" : local.cloudwatch_group_name_nodes,
          "stream_name" : "{{`{{ host }}-{{ _SYSTEMD_UNIT }}`}}",
          "create_missing_group" : false,
          "encoding" : {
            "codec" : "json"
          }
        }
      }
    }
  })

  values_sink_cloudwatch_assume_role = yamlencode({
    "customConfig" : {
      "sinks" : {
        "elasticsearch_kubernetes_containers" : {
          "auth" : {
            "assume_role" : var.k8s_assume_role_arn
          }
        },
        "elasticsearch_journal" : {
          "auth" : {
            "assume_role" : var.k8s_assume_role_arn
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
    var.cloudwatch_enabled ? local.values_sink_cloudwatch : "",
    var.cloudwatch_enabled && local.k8s_assume_role ? local.values_sink_cloudwatch_assume_role : "",
    var.values
  ])
}

data "aws_region" "current" {}

resource "helm_release" "self" {
  count            = var.enabled && !var.argo_application_enabled ? 1 : 0
  repository       = var.helm_repo_url
  chart            = var.helm_chart_name
  version          = var.helm_chart_version
  create_namespace = var.helm_create_namespace
  namespace        = var.k8s_namespace
  name             = var.helm_release_name

  values = [
    data.utils_deep_merge_yaml.values[0].output
  ]

  dynamic "set" {
    for_each = var.settings
    content {
      name  = set.key
      value = set.value
    }
  }
}
