output "server_id" {
  description = "ID of the Hetzner server."
  value       = hcloud_server.tobira.id
}

output "server_ipv4" {
  description = "Public IPv4 address of the server."
  value       = hcloud_server.tobira.ipv4_address
}
