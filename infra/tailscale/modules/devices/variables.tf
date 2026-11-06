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

variable "tailnet_domain" {
  description = "Tailnet domain for device lookups."
  type        = string
}

variable "servers" {
  description = "List of server device names (without domain)."
  type        = list(string)
  default     = ["chibi", "shiori", "tsuki"]
}

variable "storage" {
  description = "List of storage device names (without domain)."
  type        = list(string)
  default     = ["nas"]
}
