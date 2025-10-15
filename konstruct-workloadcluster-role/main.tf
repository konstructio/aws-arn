module "konstruct_downstream_role" {
  source = "../modules/konstruct-workloadcluster-role"
  
  team_cluster_oidc_endpoint = var.team_cluster_oidc_endpoint
  team_cluster_name = var.team_cluster_name

}

output "role_arn" {
  value = module.konstruct_downstream_role.role_arn
}
