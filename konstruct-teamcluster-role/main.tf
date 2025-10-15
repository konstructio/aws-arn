module "konstruct-businessmgmt" {
  source = "../modules/konstruct-businessmgmt-role"
  
  kubefirst_mgmt_cluster_oidc_endpoint     = var.kubefirst_mgmt_cluster_oidc_endpoint
  kubefirst_mgmt_cluster_name = var.kubefirst_mgmt_cluster_name
}

output "role_arn" {
  value = module.konstruct-businessmgmt.role_arn
}
