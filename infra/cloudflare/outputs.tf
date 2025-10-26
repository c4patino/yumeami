output "tunnel_id" {
  description = "ID of the Cloudflare Tunnel."
  value       = cloudflare_zero_trust_tunnel_cloudflared.yumeami.id
}

output "tunnel_name" {
  description = "Name of the Cloudflare Tunnel."
  value       = cloudflare_zero_trust_tunnel_cloudflared.yumeami.name
}

output "tunnel_account_id" {
  description = "Cloudflare Account ID for the Tunnel."
  value       = cloudflare_zero_trust_tunnel_cloudflared.yumeami.account_id
}

output "access_policy_id" {
  description = "ID of the Cloudflare Access Policy."
  value       = cloudflare_zero_trust_access_policy.allow_c4patino.id
}
