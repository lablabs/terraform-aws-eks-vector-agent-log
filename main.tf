locals {
  k8s_service_account_name = "${var.helm_chart_name}-${var.helm_release_name}"
  k8s_service_account_role = try(aws_iam_role.cloudwatch[0].arn, "")

  cloudwatch_group_name_containers = try(aws_cloudwatch_log_group.cloudwatch_containers[0].name, "")
  cloudwatch_group_name_nodes      = try(aws_cloudwatch_log_group.cloudwatch_nodes[0].name, "")

  values_default = <<-EOF
    podValuesChecksumAnnotation: true

    tolerations:
      - operator: Exists
        effect: NoSchedule

    serviceAccount:
      name: "${local.k8s_service_account_name}"
      annotations:
        eks.amazonaws.com/role-arn: ${local.k8s_service_account_role}

    # https://github.com/timberio/vector/issues/5225
    extraVolumes:
      - name: etc
        hostPath:
          path: /etc

    # https://github.com/timberio/vector/issues/5225
    extraVolumeMounts:
      - name: etc
        mountPath: /etc/machine-id
        subPath: machine-id
        readOnly: true

    sources:
      kubelet:
        type: "journald"
        include_units: ["kubelet"]
      containerd:
        type: "journald"
        include_units: ["containerd"]
      docker:
        type: "journald"
        include_units: ["docker"]
  EOF

  values_service_account_cloudwatch = <<-EOF
    serviceAccount:
      name: "${local.k8s_service_account_name}"
      annotations:
        eks.amazonaws.com/role-arn: ${local.k8s_service_account_role}
  EOF

  values_sink_cloudwatch = <<-EOF
    sinks:
      cloudwatch_containers:
        rawConfig: |
          type = "aws_cloudwatch_logs"
          inputs = ["kubernetes_logs"]
          region = "${data.aws_region.current.name}"
          group_name = "${local.cloudwatch_group_name_containers}"
          stream_name = "{{ kubernetes.pod_namespace }}-{{ kubernetes.pod_name }}-{{ kubernetes.container_name }}"
          create_missing_group = false
          encoding.codec = "json"
      cloudwatch_journal:
        rawConfig: |
          type = "aws_cloudwatch_logs"
          inputs = ["kubelet", "containerd", "docker"]
          region = "${data.aws_region.current.name}"
          group_name = "${local.cloudwatch_group_name_nodes}"
          stream_name = "{{ host }}-{{ _SYSTEMD_UNIT }}"
          create_missing_group = false
          encoding.codec = "json"
  EOF

  values = [
    local.values_default,
    var.cloudwatch_enabled ? local.values_sink_cloudwatch : "",
  ]
}

data "aws_region" "current" {}

resource "helm_release" "self" {
  count = var.enabled ? 1 : 0

  repository = var.helm_repo_url
  chart      = var.helm_chart_name
  version    = var.helm_chart_version

  create_namespace = var.k8s_create_namespace
  namespace        = var.k8s_namespace
  name             = var.helm_release_name

  values = concat(
    local.values,
    var.values
  )

  dynamic "set" {
    for_each = var.settings
    content {
      name  = set.key
      value = set.value
    }
  }
}
