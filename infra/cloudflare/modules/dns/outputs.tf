output "zone_id" {
  description = "ID of the Cloudflare zone."
  value       = cloudflare_zone.main.id
}
