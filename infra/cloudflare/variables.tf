variable "cloudflare_api_email" {
  description = "Cloudflare Account Email for Zero Trust setup."
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token with permissions for Zero Trust and Tunnel management."
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID for Zero Trust setup."
  type        = string
}

variable "allowed_email" {
  description = "Email address allowed to access the tunnel."
  type        = string
  default     = "c4patino@gmail.com"
}
