data "tls_certificate" "demo" {
  url = var.oidc_endpoint
}

resource "aws_iam_openid_connect_provider" "default" {
  url = var.oidc_endpoint

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [data.tls_certificate.demo.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "KubefirstTrustRelationship" {
  statement {
    sid = ""

    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.default.arn]
    }

    condition {
      test     = "StringLike"
      variable = "${var.oidc_endpoint}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${var.oidc_endpoint}:sub"
      values   = ["system:serviceaccount:kubefirst:kubefirst-kubefirst-pro-api"]
    }

    condition {
      test     = "StringLike"
      variable = "${var.oidc_endpoint}:sub"
      values   = ["system:serviceaccount:crossplane-system:crossplane-provider-terraform-${var.cluster_name}"]
    }
  }
}

data "aws_iam_policy_document" "KubefirstListRegionaandInstanceTypes" {
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

  statement {
    sid = ""
  }

  # Full EC2 access
  statement {
    sid    = "FullEC2Access"
    effect = "Allow"
    actions = [
      "ec2:*"
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_policy" "policy" {
  name        = "kubefirst-list-regions-and-instance-type"
  description = "This policy allows to List regions and instance type"
  policy      = data.aws_iam_policy_document.KubefirstListRegionaandInstanceTypes.json
}

resource "aws_iam_role" "kubefirst-multi-account" {
  name               = "kubefirst-pro-api-cluster-name"
  assume_role_policy = data.aws_iam_policy_document.KubefirstTrustRelationship.json

}

resource "aws_iam_role_policy_attachment" "example_attachment" {
  role       = aws_iam_role.kubefirst-multi-account.name
  policy_arn = aws_iam_policy.policy.arn
}
