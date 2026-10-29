output "zone_id" {
  description = "ID of the Cloudflare zone."
  value       = module.dns.zone_id
}

# output "tunnel_id" {
#   description = "ID of the cloudflared tunnel."
#   value       = module.tunnel.tunnel_id
# }
#
# output "warp_split_tunnel_cidrs" {
#   description = "WARP split tunnel included CIDRs."
#   value       = var.split_tunnel_cidrs
# }

# output "infra_targets" {
#   description = "Map of infrastructure target IDs keyed by machine name."
#   value       = module.access.infra_targets
# }
#
# output "ssh_access_apps" {
#   description = "Map of SSH Access app info keyed by machine name."
#   value       = module.access.ssh_access_apps
# }
