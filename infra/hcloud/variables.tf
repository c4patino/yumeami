variable "hcloud_token" {
  description = "Hetzner Cloud API token."
  type        = string
  sensitive   = true
}

variable "hcloud_ssh_keys" {
  description = "List of SSH key names registered in Hetzner Cloud."
  type        = list(string)
  default     = []
}
