# TODO
# - separate roles for kubefirst and crossplane

data "tls_certificate" "oidc_thumprint" {
  url = var.oidc_endpoint
}

resource "aws_iam_openid_connect_provider" "kubefirst_mgmt" {

  url = var.oidc_endpoint

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [data.oidc_thumprint.demo.certificates[0].sha1_fingerprint]
}
