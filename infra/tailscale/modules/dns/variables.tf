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

variable "magic_dns" {
  description = "Enable magic DNS."
  type        = bool
  default     = true
}

variable "public_nameservers" {
  description = "Public DNS nameservers to use."
  type        = list(string)
  default     = ["100.101.224.25", "1.1.1.1", "8.8.8.8"]
}

variable "split_dns" {
  description = "Split DNS configuration."
  type = list(object({
    domain     = string
    nameserver = string
  }))
  default = []
}
