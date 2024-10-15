module "kubefirst_pro" {
  source            = "github.com/konstructio/aws-arn//modules/kubefirst-pro-role?ref=main"
  oidc_endpoint     = var.oidc_endpoint
  mgmt_cluster_name = var.mgmt_cluster_name
}

output "role_arn" {
  value = module.kubefirst_pro.role_arn
}
