variable "account_id" {
  description = "Cloudflare Account ID where the tunnel is created."
  type        = string
}

variable "zone_id" {
  description = "ID of the zone that hosts the wildcard tunnel DNS record."
  type        = string
}
