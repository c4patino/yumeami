output "tunnel_id" {
  description = "ID of the cloudflared tunnel."
  value       = cloudflare_zero_trust_tunnel_cloudflared.yumeami.id
}
