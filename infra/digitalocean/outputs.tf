output "project_id" {
  description = "ID of the DigitalOcean project."
  value       = digitalocean_project.yumeami.id
}

output "droplet_id" {
  description = "ID of the DigitalOcean Droplet."
  value       = digitalocean_droplet.tobira.id
}

output "droplet_ipv4" {
  description = "Public IPv4 address of the Droplet."
  value       = digitalocean_droplet.tobira.ipv4_address
}

output "droplet_ipv6" {
  description = "Public IPv6 address of the Droplet."
  value       = digitalocean_droplet.tobira.ipv6_address
}
