output "service_id" {
  value       = "svc-${var.environment}-${var.service_name}"
  description = "Synthetic service identifier"
}
