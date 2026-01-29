output "network_id" {
  value       = terraform_data.network.output.id
  description = "Synthetic network identifier"
}

output "cidr" {
  value       = terraform_data.network.output.cidr
  description = "Network CIDR"
}
