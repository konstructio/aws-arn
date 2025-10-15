> [!WARNING]  
> Before running the terraform command make sure you have correct credentials set() and correct region in the aws provider.

1. Create `terraform.tfvars` file with OIDC endpoint from managment cluster and cluster name
```
oidc_endpoint     = "value"
mgmt_cluster_name = "value"
```

3. Run terraform init to donwload the aws provider and configure local state file
```bash
terraform init
```

4. Run terraform apply to create an idenity provider and role to allow crossplane and kubefirst to access the downstream account in `us-east-1` region.
```bash
terraform apply
```

5. To view the role arn 
```bash
terraform output
```
