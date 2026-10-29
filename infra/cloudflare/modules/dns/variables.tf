variable "account_id" {
  description = "Cloudflare Account ID that owns the zone."
  type        = string
}

variable "zone_name" {
  description = "Primary zone/domain name managed by this module."
  type        = string
}
