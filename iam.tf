locals {
  irsa_role_create = var.enabled && var.rbac_create && var.service_account_create && var.irsa_role_create
}

data "aws_iam_policy_document" "cloudwatch" {
  count = local.irsa_role_create && var.cloudwatch_enabled && !var.irsa_assume_role_enabled ? 1 : 0

  statement {
    sid = "AllowDescribeCloudWatchLogsForVector"

    actions   = ["logs:DescribeLogGroups"]
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

data "aws_iam_policy_document" "cloudwatch_assume" {
  count = local.irsa_role_create && var.cloudwatch_enabled && var.irsa_assume_role_enabled ? 1 : 0
  statement {
    sid = "AllowAssumeCloudwatchRole"

    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      var.irsa_assume_role_arn
    ]
  }
}

resource "aws_iam_policy" "cloudwatch" {
  count = local.irsa_role_create && var.cloudwatch_enabled ? 1 : 0

  name        = "${var.irsa_role_name_prefix}-${var.helm_chart_name}-cloudwatch"
  path        = "/"
  description = "Policy for vector logging cloudwatch sink"
  policy      = var.irsa_assume_role_enabled ? data.aws_iam_policy_document.cloudwatch_assume[0].json : data.aws_iam_policy_document.cloudwatch[0].json
  tags        = var.irsa_tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count = local.irsa_role_create && var.cloudwatch_enabled ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.cloudwatch[0].arn
}

data "aws_iam_policy_document" "opensearch" {
  count = local.irsa_role_create && var.opensearch_enabled && !var.irsa_assume_role_enabled ? 1 : 0
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

data "aws_iam_policy_document" "opensearch_assume" {
  count = local.irsa_role_create && var.opensearch_enabled && var.irsa_assume_role_enabled ? 1 : 0
  statement {
    sid = "AllowAssumeOpenSearchRole"

    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      var.irsa_assume_role_arn
    ]
  }
}

resource "aws_iam_policy" "opensearch" {
  count = local.irsa_role_create && var.opensearch_enabled ? 1 : 0

  name        = "${var.irsa_role_name_prefix}-${var.helm_chart_name}-opensearch"
  path        = "/"
  description = "Policy for vector logging opensearch sink"
  policy      = var.irsa_assume_role_enabled ? data.aws_iam_policy_document.opensearch_assume[0].json : data.aws_iam_policy_document.opensearch[0].json
}

resource "aws_iam_role_policy_attachment" "opensearch" {
  count = local.irsa_role_create && var.opensearch_enabled ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.opensearch[0].arn
}

#This policy document is used nowhere
data "aws_iam_policy_document" "this_irsa" {
  count = local.irsa_role_create ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.cluster_identity_oidc_issuer_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_identity_oidc_issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account_name}",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "this" {
  count = local.irsa_role_create ? 1 : 0

  name               = "${var.irsa_role_name_prefix}-${var.helm_chart_name}"
  assume_role_policy = data.aws_iam_policy_document.this_irsa[0].json
  tags               = var.irsa_tags
}

resource "aws_iam_role_policy_attachment" "this_additional" {
  for_each = local.irsa_role_create ? var.irsa_additional_policies : {}

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
