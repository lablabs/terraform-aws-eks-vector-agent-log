locals {
  irsa_policy_enabled      = var.irsa_policy_enabled != null ? var.irsa_policy_enabled : (local.cloudwatch_enabled || local.opensearch_enabled) && coalesce(var.irsa_assume_role_enabled, false) == false
  irsa_assume_role_enabled = var.irsa_assume_role_enabled != null ? var.irsa_assume_role_enabled : false
}

data "aws_iam_policy_document" "cloudwatch" {
  count = local.cloudwatch_enabled && local.irsa_policy_enabled && var.irsa_policy == null ? 1 : 0

  statement {
    sid = "AllowDescribeCloudWatchLogsForVector"

    actions = ["logs:DescribeLogGroups"]

    #checkov:skip=CKV_AWS_356: Allow all kms actions for * resources here
    resources = ["*"]
  }

  statement {
    sid = "AllowCloudWatchLogsForVector"

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "${aws_cloudwatch_log_group.cloudwatch_containers[0].arn}:*",
      "${aws_cloudwatch_log_group.cloudwatch_nodes[0].arn}:*"
    ]
  }
}


data "aws_iam_policy_document" "opensearch" {
  count = local.opensearch_enabled && local.irsa_policy_enabled && var.irsa_policy == null ? 1 : 0

  statement {
    sid = "AllowOpenSearchLogsForVector"

    actions = [
      "es:ESHttpGet",
      "es:ESHttpPut",
      "es:ESHttpPost"
    ]

    resources = var.opensearch_domain_arn
  }
}

data "aws_iam_policy_document" "vector" {
  count = var.enabled && local.irsa_policy_enabled && var.irsa_policy == null ? 1 : 0

  source_policy_documents = compact([
    one(data.aws_iam_policy_document.cloudwatch[*].json),
    one(data.aws_iam_policy_document.opensearch[*].json)
  ])
}
