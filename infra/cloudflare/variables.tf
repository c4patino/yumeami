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

variable "access_base_domain" {
  description = "Base domain used to create per-node Access SSH app hostnames (e.g., infra.example.com). Leave empty to disable app creation."
  type        = string
  default     = ""
}

variable "access_allowed_emails" {
  description = "Emails allowed to access infrastructure SSH apps."
  type        = list(string)
  default     = []
}

variable "access_allowed_group_ids" {
  description = "Cloudflare Access group IDs allowed to access infrastructure SSH apps."
  type        = list(string)
  default     = []
}

variable "session_duration" {
  description = "Cloudflare Access session duration for SSH apps (e.g., 24h)."
  type        = string
  default     = "24h"
}

variable "require_warp" {
  description = "Whether to require WARP device posture for SSH Access policies."
  type        = bool
  default     = true
}

variable "split_tunnel_cidrs" {
  description = "CIDR ranges to include in WARP split tunnel (mode is hardcoded to include)."
  type        = list(string)
  default = [
    "10.0.1.0/24",
  ]
}

variable "machines" {
  description = "Infrastructure nodes for SSH access. If ip is null, resources for that node will be skipped."
  type = list(object({
    name        = string
    ip          = string
    ssh_port    = number
    description = string
  }))
  default = [
    {
      name        = "arisu"
      ip          = null
      ssh_port    = 22
      description = ""
    },
    {
      name        = "chibi"
      ip          = null
      ssh_port    = 22
      description = ""
    },
    {
      name        = "kokoro"
      ip          = null
      ssh_port    = 22
      description = ""
    },
    {
      name        = "shiori"
      ip          = null
      ssh_port    = 22
      description = ""
    },
  ]
}
