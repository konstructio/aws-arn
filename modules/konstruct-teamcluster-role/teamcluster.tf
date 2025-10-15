data "aws_iam_policy_document" "konstruct_trust_relationship" {
  statement {
    sid = "KonstructAPITrustRelationship"

    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.kubefirst_mgmt.arn]
    }

    condition {
      test     = "StringLike"
      variable = replace("${data.tls_certificate.oidc_provider_mgmt.url}:aud", "https://", "")
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = replace("${data.tls_certificate.oidc_provider_mgmt.url}:sub", "https://", "")
      values   = ["system:serviceaccount:konstruct:konstruct-api"]
    }
  }

  statement {
    sid = "KonstructOperatorRelationship"

    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.kubefirst_mgmt.arn]
    }

    condition {
      test     = "StringLike"
      variable = replace("${data.tls_certificate.oidc_provider_mgmt.url}:aud", "https://", "")
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = replace("${data.tls_certificate.oidc_provider_mgmt.url}:sub", "https://", "")
      values   = ["system:serviceaccount:konstruct-system:konstruct-downstream"]
    }
  }

  statement {
    sid = "CrossplaneTrustRelationship"

    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.kubefirst_mgmt.arn]
    }

    condition {
      test     = "StringLike"
      variable = replace("${data.tls_certificate.oidc_provider_mgmt.url}:aud", "https://", "")
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = replace("${data.tls_certificate.oidc_provider_mgmt.url}:sub", "https://", "")
      values   = ["system:serviceaccount:crossplane-system:crossplane-provider-terraform-${var.kubefirst_mgmt_cluster_name}"]
    }
  }
}

# permission policy to allow konstruct-api pod in managment cluster
# to list Instance types and Regions
data "aws_iam_policy_document" "konstruct_list_region_and_instance_types" {
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
      "eks:*",
      "s3:*"
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

resource "aws_iam_policy" "konstruct" {
  name        = "konstruct-${var.kubefirst_mgmt_cluster_name}"
  description = "Konstruct (Controller,API) and Crossplane access"
  policy      = data.aws_iam_policy_document.konstruct_list_region_and_instance_types.json
}

resource "aws_iam_role" "konstruct" {
  name               = "konstruct-${var.kubefirst_mgmt_cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.konstruct_trust_relationship.json
}

resource "aws_iam_role_policy_attachment" "konstruct" {
  role       = aws_iam_role.konstruct.name
  policy_arn = aws_iam_policy.konstruct.arn
}

