module "kubefirst_pro" {
  source        = "github.com/konstructio/aws-arn?ref=main"
  oidc_endpoint = var.oidc_endpoint
  cluster_name  = var.cluster_name
}

output "role_arn" {
  value = module.kubefirst_pro.role_arn
}
