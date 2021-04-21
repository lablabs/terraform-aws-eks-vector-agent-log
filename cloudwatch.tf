resource "aws_cloudwatch_log_group" "cloudwatch_containers" {
  count = var.enabled && var.cloudwatch_enabled ? 1 : 0

  name              = "${var.cloudwatch_group_name_prefix}/containers"
  retention_in_days = var.cloudwatch_group_containers_retention
  kms_key_id        = var.cloudwatch_group_containers_kms_key_id

  tags = var.cloudwatch_nodes_tags
}

resource "aws_cloudwatch_log_group" "cloudwatch_nodes" {
  count = var.enabled && var.cloudwatch_enabled ? 1 : 0

  name              = "${var.cloudwatch_group_name_prefix}/nodes"
  retention_in_days = var.cloudwatch_group_nodes_retention
  kms_key_id        = var.cloudwatch_group_nodes_kms_key_id

  tags = var.cloudwatch_containers_tags
}
