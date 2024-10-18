# Trust policy to allow kubefirst-pro-api in managment cluster
# to assume below role in the downstream account
# TODO: remove crossplane trust relationship 
data "aws_iam_policy_document" "kubefirst_trust_relationship" {
  statement {
    sid = "KubefirstTrustRelationship"

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
      variable = replace("${data.tls_certificate.oidc_provider.url}:aud", "https://", "")
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = replace("${data.tls_certificate.oidc_provider.url}:sub", "https://", "")
      values   = ["system:serviceaccount:kubefirst:kubefirst-kubefirst-pro-api"]
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
      variable = replace("${data.tls_certificate.oidc_provider.url}:aud", "https://", "")
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = replace("${data.tls_certificate.oidc_provider.url}:sub", "https://", "")
      values   = ["system:serviceaccount:crossplane-system:crossplane-provider-terraform-${var.mgmt_cluster_name}"]
    }
  }
}

# permission policy to allow kubefirst-pro-api pod in managment cluster
# to list Instance types and Regions
data "aws_iam_policy_document" "kubefirst_list_region_and_instance_types" {
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
      # "iam:GetRole",
      # "iam:CreatePolicy",
      # "iam:GetPolicy",
      # "iam:GetPolicyVersion",
      # "iam:ListPolicyVersions",
      # "iam:DeletePolicy",
      # "logs:CreateLogGroup",
      "logs:TagResource",
      "logs:PutRetentionPolicy",
      # "iam:CreateRole",
      # "iam:TagPolicy",
      "logs:DescribeLogGroups",
      "logs:ListTagsForResource",
      "logs:CreateLogGroup",
      # "iam:TagRole",
      "iam:*",
      # "logs*"
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_policy" "kubefirst_pro_api" {
  name        = "kubefirst-list-regions-and-instance-types-${var.mgmt_cluster_name}"
  description = "List regions and instance types in the account"
  policy      = data.aws_iam_policy_document.kubefirst_list_region_and_instance_types.json
}

resource "aws_iam_role" "kubefirst_pro_api" {
  name               = "kubefirst-pro-api-${var.mgmt_cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.kubefirst_trust_relationship.json

}

resource "aws_iam_role_policy_attachment" "kubefirst_pro_api" {
  role       = aws_iam_role.kubefirst_pro_api.name
  policy_arn = aws_iam_policy.kubefirst_pro_api.arn
}

