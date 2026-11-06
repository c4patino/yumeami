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
  description = "Tailnet ID."
  type        = string
}