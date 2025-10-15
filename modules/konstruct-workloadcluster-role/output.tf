output "role_arn" {
  value       = [aws_iam_role.konstruct_downstream_role.arn]
  description = "Konstruct Downstream role arn"
}
