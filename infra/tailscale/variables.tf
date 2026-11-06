variable "tailscale_oauth_client_id" {
  description = "OAuth client ID for Tailscale API authentication."
  type        = string
  sensitive   = true
}

variable "tailscale_oauth_client_secret" {
  description = "OAuth client secret for Tailscale API authentication."
  type        = string
  sensitive   = true
}

variable "tailscale_tailnet_id" {
  description = "Tailnet ID (optional, uses default if not specified)."
  type        = string
  default     = "TeToZSS3vB21CNTRL"
}

variable "tailscale_tailnet_domain" {
  description = "Tailnet domain (e.g., tail8b9fd9.ts.net)."
  type        = string
  default     = "tail8b9fd9.ts.net"
}

variable "tailscale_email" {
  description = "Email for contacts and ACL policies."
  type        = string
}
