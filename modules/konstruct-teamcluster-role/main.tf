data "tls_certificate" "oidc_provider_mgmt" {
  url = var.kubefirst_mgmt_cluster_oidc_endpoint
}

resource "aws_iam_openid_connect_provider" "kubefirst_mgmt" {
  url = var.kubefirst_mgmt_cluster_oidc_endpoint

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [data.tls_certificate.oidc_provider_mgmt.certificates[0].sha1_fingerprint]
}
