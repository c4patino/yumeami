output "zone_id" {
  description = "ID of the Cloudflare zone."
  value       = cloudflare_zone.main.id
}

output "warp_split_tunnel_cidrs" {
  description = "WARP split tunnel included CIDRs."
  value       = var.split_tunnel_cidrs
}

output "infra_targets" {
  description = "Map of infrastructure target IDs keyed by machine name."
  value = {
    for k, v in cloudflare_zero_trust_access_infrastructure_target.ssh : k => v.id
  }
}

output "ssh_access_apps" {
  description = "Map of SSH Access app info keyed by machine name."
  value = {
    for k, v in cloudflare_zero_trust_access_application.ssh : k => {
      id      = v.id
      domain  = v.domain
      name    = v.name
      type    = v.type
      zone_id = try(v.zone_id, null)
    }
  }
}
