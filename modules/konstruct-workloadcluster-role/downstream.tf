data "aws_iam_policy_document" "konstruct_trust_relationship" {
  statement {
    sid = "CrossplaneTrustRelationship"

    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.konstruct_business_mgmt.arn]
    }

    condition {
      test     = "StringLike"
      variable = replace("${data.tls_certificate.oidc_provider.url}:aud", "https://", "")
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = replace("${data.tls_certificate.oidc_provider.url}:sub", "https://", "")
      values   = ["system:serviceaccount:crossplane-system:crossplane-provider-terraform-${var.team_cluster_name}"]
    }
  }
}

data "aws_iam_policy_document" "crossplane_access" {
  statement {
    sid = "ListInstanceTypes"

    effect = "Allow"

    actions = [
      "ec2:DescribeInstanceTypeOfferings",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "ListRegions"

    actions = [
      "account:ListRegions",
    ]

    resources = [
      "*",
    ]
  }

  
  # Full EC2 access (required for crossplane)
  # TODO: narrow down premission required for crossplane
  statement {
    sid    = "AdminAccess"
    effect = "Allow"
    actions = [
      "ec2:*",
      "eks:*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CreatePolicies"
    effect = "Allow"
    actions = [
      "iam:*",
      "logs:*",
      "ssm:*"
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_policy" "konstruct_downstream_role" {
  name        = "businessmgmt-crossplane-access-${var.team_cluster_name}"
  description = "Business Mgmt Cross Plane access"
  policy      = data.aws_iam_policy_document.crossplane_access.json
}

resource "aws_iam_role" "konstruct_downstream_role" {
  name               = "downstream-${var.team_cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.konstruct_trust_relationship.json
}

resource "aws_iam_role_policy_attachment" "konstruct_downstream_role" {
  role       = aws_iam_role.konstruct_downstream_role.name
  policy_arn = aws_iam_policy.konstruct_downstream_role.arn
}

