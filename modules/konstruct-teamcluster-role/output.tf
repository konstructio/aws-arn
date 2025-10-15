output "role_arn" {
  value       = [aws_iam_role.konstruct.arn]
  description = "Konstruct Business Mgmt role arn"
}
