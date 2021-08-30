data "aws_iam_policy_document" "vector_irsa_assume" {
  count = var.enabled ? 1 : 0

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

data "aws_iam_policy_document" "cloudwatch" {
  count = var.enabled && var.cloudwatch_enabled ? 1 : 0

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
  count = var.enabled && var.cloudwatch_enabled ? 1 : 0

  name        = "${var.cloudwatch_role_name_prefix}-${var.helm_chart_name}"
  path        = "/"
  description = "Policy for cluster-autoscaler service"
  policy      = data.aws_iam_policy_document.cloudwatch[0].json
}

resource "aws_iam_role" "cloudwatch" {
  count = var.enabled && var.cloudwatch_enabled ? 1 : 0

  name               = "${var.cloudwatch_role_name_prefix}-${var.helm_chart_name}"
  assume_role_policy = data.aws_iam_policy_document.vector_irsa_assume[0].json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count = var.enabled && var.cloudwatch_enabled ? 1 : 0

  role       = aws_iam_role.cloudwatch[0].name
  policy_arn = aws_iam_policy.cloudwatch[0].arn
}
