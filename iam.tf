locals {
  k8s_assume_role = length(var.k8s_assume_role_arn) > 0 ? true : false
}

data "aws_iam_policy_document" "cloudwatch" {
  count = local.k8s_irsa_role_create && var.cloudwatch_enabled ? 1 : 0

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

resource "aws_iam_policy" "cloudwatch" {
  count = local.k8s_irsa_role_create && var.cloudwatch_enabled ? 1 : 0

  name        = "${var.k8s_irsa_role_name_prefix}-${var.helm_chart_name}-cloudwatch"
  path        = "/"
  description = "Policy for vector logging cloudwatch sink"
  policy      = local.k8s_assume_role ? data.aws_iam_policy_document.cloudwatch_assume[0].json : data.aws_iam_policy_document.cloudwatch[0].json
}

data "aws_iam_policy_document" "cloudwatch_assume" {
  count = local.k8s_irsa_role_create && var.cloudwatch_enabled && local.k8s_assume_role ? 1 : 0
  statement {
    sid = "AllowAssumeCloudwatchRole"

    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      var.k8s_assume_role_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count = local.k8s_irsa_role_create && var.cloudwatch_enabled ? 1 : 0

  role       = aws_iam_role.vector[0].name
  policy_arn = aws_iam_policy.cloudwatch[0].arn
}

data "aws_iam_policy_document" "opensearch" {
  count = local.k8s_irsa_role_create && var.opensearch_enabled && !local.k8s_assume_role ? 1 : 0
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
  count = local.k8s_irsa_role_create && var.opensearch_enabled && local.k8s_assume_role ? 1 : 0
  statement {
    sid = "AllowAssumeOpenSearchRole"

    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      var.k8s_assume_role_arn
    ]
  }
}

resource "aws_iam_policy" "opensearch" {
  count = local.k8s_irsa_role_create && var.opensearch_enabled ? 1 : 0

  name        = "${var.k8s_irsa_role_name_prefix}-${var.helm_chart_name}-opensearch"
  path        = "/"
  description = "Policy for vector logging opensearch sink"
  policy      = local.k8s_assume_role ? data.aws_iam_policy_document.opensearch_assume[0].json : data.aws_iam_policy_document.opensearch[0].json
}

resource "aws_iam_role_policy_attachment" "opensearch" {
  count = local.k8s_irsa_role_create && var.opensearch_enabled ? 1 : 0

  role       = aws_iam_role.vector[0].name
  policy_arn = aws_iam_policy.opensearch[0].arn
}

data "aws_iam_policy_document" "vector_irsa" {
  count = local.k8s_irsa_role_create ? 1 : 0

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
        "system:serviceaccount:${var.k8s_namespace}:${local.k8s_service_account_name}",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "vector" {
  count = local.k8s_irsa_role_create ? 1 : 0

  name               = "${var.k8s_irsa_role_name_prefix}-${var.helm_chart_name}"
  assume_role_policy = data.aws_iam_policy_document.vector_irsa[0].json
}
