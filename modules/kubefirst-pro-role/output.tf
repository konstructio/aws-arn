output "role_arn" {
  value       = [aws_iam_role.kubefirst_pro_api.arn]
  description = "Kubefirst Pro role arn"
}
