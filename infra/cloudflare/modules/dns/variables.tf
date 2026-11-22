variable "account_id" {
  description = "Cloudflare Account ID that owns the zone."
  type        = string
}

variable "zone_name" {
  description = "Primary zone/domain name managed by this module."
  type        = string
}

variable "wildcard_a_record" {
  description = "IPv4 address for the wildcard A record."
  type        = string
  default     = ""
}

variable "wildcard_aaaa_record" {
  description = "IPv6 address for the wildcard AAAA record."
  type        = string
  default     = ""
}
