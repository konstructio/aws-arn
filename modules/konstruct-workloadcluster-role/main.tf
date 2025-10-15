data "tls_certificate" "oidc_provider" {
  url = var.team_cluster_oidc_endpoint
}

resource "aws_iam_openid_connect_provider" "konstruct_business_mgmt" {

  url = var.team_cluster_oidc_endpoint

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [data.tls_certificate.oidc_provider.certificates[0].sha1_fingerprint]
}
